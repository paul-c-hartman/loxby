require_relative 'loxby'
require_relative 'errors'
require_relative 'visitors/base'

class Interpreter < Visitor
  def initialize(process)
    @process = process
  end

  def interpret(expr)
    value = evaluate expr
    puts lox_obj_to_str(value)
  rescue Lox::RunError => e
    @process.runtime_error e
  end

  def evaluate(expr)
    expr.accept self
  end

  # Lox's definition of truthiness follows
  # Ruby's by definition. This does nothing.
  def truthy?(obj)
    obj
  end

  def ensure_number(operator, *objs)
    raise Lox::RunError.new(operator, "Operand must be a number.") unless objs.all? { _1.is_a?(Float) }
  end

  def lox_obj_to_str(obj)
    case obj
    when nil
      'nil'
    when Float
      if obj.to_s[-2..] == '.0'
        obj.to_s[0...-2]
      end
    else
      obj.to_s
    end
  end

  # Leaves of the AST. The scanner picks
  # out these values for us beforehand.
  def visit_literal_expression(expr)
    expr.value
  end

  def visit_grouping_expression(expr)
    evaluate expr
  end

  def visit_unary_expression(expr)
    right = evaluate(expr.right)

    case expr.operator.type
    when :minus
      ensure_number(expr.operator, right)
      -(right.to_f)
    when :bang
      truthy? right
    end
  end

  def visit_binary_expression(expr)
    left = evaluate expr.left
    right = evaluate expr.right
    case expr.operator.type
    when :minus
      ensure_number(expr.operator, left, right)
      left.to_f - right.to_f
    when :slash
      raise Lox::DividedByZeroError.new(expr.operator, "Cannot divide by zero.") if right == 0.0
      ensure_number(expr.operator, left, right)
      left.to_f / right.to_f
    when :star
      ensure_number(expr.operator, left, right)
      left.to_f * right.to_f
    when :plus
      if (left.is_a?(Float) || left.is_a?(String)) && left.class == right.class
        left + right
      else
        raise Lox::RunError.new(expr.operator, "Operands must be two numbers or two strings.")
      end
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
    left = evaluate expr.left
    
    left ? evaluate(expr.center) : evaluate(expr.right)
  end
end