# frozen_string_literal: true

class Lox
  # Interpreter class. Walks the AST using
  # the Visitor pattern.
  class Interpreter < Visitors::BaseVisitor
    attr_reader :globals, :process

    def initialize(process) # rubocop:disable Lint/MissingSuper
      @process = process
      # `@globals` always refers to the same environment regardless of scope.
      @globals = Lox::Helpers::Environment.new
      # `@environment` changes based on scope.
      @environment = @globals
      # `@locals` stores resolved variable references from the `Resolver`'s
      # semantic analysis pass.
      @locals = {}
      define_native_functions
    end

    def interpret(statements)
      result = nil
      statements.each { result = lox_eval(_1) }
      result
    rescue Lox::RunError => e
      @process.runtime_error e
      nil
    end

    # Native extension interface for Loxby.
    #
    # For example, to extend the base
    # interpreter directly:
    #
    # ```ruby
    # require 'loxby/interpreter'
    # require 'loxby/helpers/native_functions'
    # Interpreter.native_function(:greet, arity: 1) { |_interpreter, args| puts "Hello #{args[0]}!" }
    # ```
    #
    # Or inside a modified interpreter:
    # ```ruby
    # require 'loxby/interpreter'
    # require 'loxby/helpers/native_functions'
    # class MyInterpreter < Interpreter
    #   ...
    #   native_function :greet, arity: 1, &->(_interpreter, args) { puts "Hello #{args[0]}!" }
    # end
    # ```
    def self.native_function(name, arity:, &block)
      Lox::Config.native_functions << { name:, arity:, block: }
    end

    def define_native_functions
      Lox::Config.native_functions.each do |func|
        @globals.set func[:name].to_s, Lox::Helpers::NativeFunction.new(func[:arity], &func[:block])
      end
    end

    def lox_eval(expr)
      expr.accept self
    end

    # Lox's definition of truthiness follows
    # Ruby's (for now), so this is a no-op (for now)
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

    def look_up_variable(name, expr)
      # If variable was picked up by resolver, use that,
      # otherwise look it up in `@globals`
      if @locals[expr]
        @environment.get_at(@locals[expr], name.lexeme)
      else
        @globals[name]
      end
    end

    def visit_expression_statement(statement)
      lox_eval statement.expression
    end

    def visit_function_statement(statement)
      function = Lox::Function.new(statement, @environment)
      @environment[statement.name] = function if statement.name
      function
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

    def visit_return_statement(statement)
      value = statement.value.nil? ? nil : lox_eval(statement.value)
      throw :return, value # This is not an error, just sending a message up the callstack
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
      look_up_variable(expr.name, expr)
    end

    def visit_assign_expression(expr)
      value = lox_eval expr.value

      # if @locals[expr].nil?
      #   @environment.assign_at(distance, expr.name, value)
      # else
      #   @globals.assign(expr.name, value)
      # end
      @locals[expr] ? @environment.assign_at(@locals[expr], expr.name.lexeme, value) : @globals.assign(expr.name, value)

      value
    end

    def visit_block_statement(statement)
      # Pull out a copy of the environment
      # so that blocks are closures
      execute_block(statement.statements, Lox::Environment.new(@environment))
    end

    def visit_break_statement(_)
      throw :break
    end

    def execute_block(statements, environment)
      previous = @environment
      @environment = environment
      statements.each { lox_eval _1 }
      nil
    # rescue Lox::RunError => e
    #   @process.runtime_error e
    #   nil
    ensure
      @environment = previous
    end

    def resolve(expr, depth)
      @locals[expr] = depth
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
      lox_eval expr.expression
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
      when :percent
        left % right
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

    def visit_call_expression(expr) # rubocop:disable Metrics/AbcSize
      callee = lox_eval expr.callee
      arguments = expr.arguments.map { lox_eval _1 }

      unless callee.class.include? Lox::Callable
        raise Lox::RunError.new(expr.paren, 'Can only call functions and classes.')
      end

      unless arguments.size == callee.arity
        raise Lox::RunError.new(expr.paren, "Expected #{callee.arity} arguments but got #{arguments.size}.")
      end

      callee.call(self, arguments)
    end
  end
end

Lox::Interpreter.native_function :clock, arity: 0, &->(_int, _args) { Time.now.to_f }
Lox::Interpreter.native_function :exit, arity: 0, &->(_int, _args) { throw :lox_exit }
Lox::Interpreter.native_function(:_inspectLocalScope, arity: 0) do |interpreter, _args|
  puts <<~OUT
    ~~~~
    LOCAL SCOPE INSPECTOR
    ====
    Found by resolver:
    #{interpreter.instance_variable_get(:@locals).map { "#{_1.lexeme}: #{interpreter.environment.get_at(@locals[_1], _1.lexeme)}" }.join("\n")}
    ====
    Found in globals:
    #{interpreter.globals.values.map { |name, value| "#{name}: #{value}" }.join("\n")}
    ~~~~
  OUT
end
