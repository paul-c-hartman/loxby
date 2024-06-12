# frozen_string_literal: true

require_relative 'helpers/environment'
require_relative 'helpers/errors'
require_relative 'visitors/base'

# Interpreter class. Walks the AST using
# the Visitor pattern.
class Interpreter < Visitor
  def initialize(process) # rubocop:disable Lint/MissingSuper
    @process = process
    @environment = Lox::Environment.new
  end

  def interpret(statements)
    result = nil
    statements.each { result = lox_eval(_1) }
    result
  rescue Lox::RunError => e
    @process.runtime_error e
    nil
  end

  def lox_eval(expr)
    expr.accept self
  end

  # Lox's definition of truthiness follows
  # Ruby's by definition. This does nothing.
  def truthy?(obj)
    obj
  end

  def ensure_number(operator, *objs)
    raise Lox::RunError.new(operator, 'Operand must be a number.') unless objs.all? { _1.is_a?(Float) }
  end

  def lox_obj_to_str(obj)
    case obj
    when nil
      'nil'
    when Float
      obj.to_s[-2..] == '.0' ? obj.to_s[0...-2] : obj.to_s
    else
      obj.to_s
    end
  end

  def visit_expression_statement(statement)
    lox_eval statement.expression
  end

  def visit_if_statement(statement)
    if truthy? lox_eval(statement.condition)
      lox_eval statement.then_branch
    elsif !statement.else_branch.nil?
      lox_eval statement.else_branch
    end
  end

  def visit_print_statement(statement)
    value = lox_eval statement.expression
    puts lox_obj_to_str(value)
  end

  def visit_var_statement(statement)
    value = statement.initializer ? lox_eval(statement.initializer) : nil
    @environment[statement.name] = value
  end

  def visit_while_statement(statement)
    catch :break do # Jump beacon for break statements
      value = nil
      (value = lox_eval statement.body) while truthy?(lox_eval(statement.condition))
      value
    end
  end

  def visit_variable_expression(expr)
    @environment[expr.name]
  end

  def visit_assign_expression(expr)
    value = lox_eval expr.value
    @environment.assign expr.name, value
    value
  end

  def visit_block_statement(statement)
    execute_block(statement.statements, Lox::Environment.new(@environment))
  end

  def visit_break_statement(_)
    throw :break
  end

  def execute_block(statements, environment)
    value = nil
    previous = @environment
    @environment = environment
    statements.each { value = lox_eval _1 }
    value
  rescue Lox::RunError
    nil
  ensure
    @environment = previous
  end

  # Leaves of the AST. The scanner picks
  # out these values for us beforehand.
  def visit_literal_expression(expr)
    expr.value
  end

  def visit_logical_expression(expr)
    left = lox_eval expr.left

    case expr.operator.type
    when :or
      left if truthy? left
    else # Just and, for now
      truthy?(left) ? lox_eval(expr.right) : left
    end
  end

  def visit_grouping_expression(expr)
    lox_eval expr
  end

  def visit_unary_expression(expr)
    right = lox_eval(expr.right)

    case expr.operator.type
    when :minus
      ensure_number(expr.operator, right)
      -right.to_f
    when :bang
      truthy? right
    end
  end

  def visit_binary_expression(expr) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/AbcSize
    left = lox_eval expr.left
    right = lox_eval expr.right
    case expr.operator.type
    when :minus
      ensure_number(expr.operator, left, right)
      left.to_f - right.to_f
    when :slash
      raise Lox::DividedByZeroError.new(expr.operator, 'Cannot divide by zero.') if right == 0.0

      ensure_number(expr.operator, left, right)
      left.to_f / right
    when :star
      ensure_number(expr.operator, left, right)
      left.to_f * right.to_f
    when :plus
      unless (left.is_a?(Float) || left.is_a?(String)) && left.instance_of?(right.class)
        raise Lox::RunError.new(expr.operator, 'Operands must be two numbers or two strings.')
      end

      left + right
    when :greater
      ensure_number(expr.operator, left, right)
      left.to_f > right.to_f
    when :greater_equal
      ensure_number(expr.operator, left, right)
      left.to_f >= right.to_f
    when :less
      ensure_number(expr.operator, left, right)
      left.to_f < right.to_f
    when :less_equal
      ensure_number(expr.operator, left, right)
      left.to_f <= right.to_f
    when :bang_equal
      left != right
    when :equal_equal
      left == right
    when :comma
      right
    end
  end

  def visit_ternary_expression(expr)
    left = lox_eval expr.left

    left ? lox_eval(expr.center) : lox_eval(expr.right)
  end
end
