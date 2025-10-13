# frozen_string_literal: true
# typed: strict

class Lox
  # Interpreter class. Walks the AST using
  # the Visitor pattern.
  class Interpreter
    extend T::Sig
    include Lox::Visitor

    sig { params(process: Lox).void }
    def initialize(process)
      @process = process
    end

    sig { override.params(expr: Expression::Literal).returns(Lox::Object) }
    def visit_literal_expr(expr) # rubocop:disable Metrics/MethodLength
      value = expr.value
      case value
      when String
        Lox::Object::String.new(value:)
      when Integer, Float
        Lox::Object::Num.new(value:)
      when TrueClass, FalseClass
        Lox::Object::Bool.new(value:)
      when NilClass
        Lox::Object::Nil.new
      end
    end

    sig { override.params(expr: Expression::Grouping).returns(Lox::Object) }
    def visit_grouping_expr(expr)
      evaluate expr.expression
    end

    sig { override.params(expr: Expression::Unary).returns(Lox::Object) }
    def visit_unary_expr(expr) # rubocop:disable Metrics/AbcSize
      right = evaluate expr.right

      case expr.operator.type
      when :minus
        check_types type: Lox::Object::Num, objects: [right], token: expr.operator

        return Lox::Object::Num.new(value: right.value * -1)
      when :bang
        check_types type: Lox::Object::Bool, objects: [right], token: expr.operator

        return Lox::Object::Bool.new(value: !right.value)
      end

      raise "Unknown unary operator: #{expr.operator.type}"
    end

    sig { override.params(expr: Expression::Binary).returns(Lox::Object) }
    def visit_binary_expr(expr) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      left = evaluate expr.left
      right = evaluate expr.right

      case expr.operator.type
      when :plus
        if left.is_a?(Lox::Object::Num) && right.is_a?(Lox::Object::Num)
          Lox::Object::Num.new(value: left.value + right.value)
        elsif left.is_a?(Lox::Object::String) && right.is_a?(Lox::Object::String)
          Lox::Object::String.new(value: left.value + right.value)
        else
          error! expr.operator, 'Operands must be two numbers or two strings.'
        end
      when :minus
        check_types type: Lox::Object::Num, objects: [left, right], token: expr.operator
        Lox::Object::Num.new(value: left.value - right.value)
      when :star
        check_types type: Lox::Object::Num, objects: [left, right], token: expr.operator
        Lox::Object::Num.new(value: left.value * right.value)
      when :slash
        check_types type: Lox::Object::Num, objects: [left, right], token: expr.operator
        Lox::Object::Num.new(value: left.value / right.value)
      when :comma
        # Discard left operand
        right
      when :greater
        Lox::Object::Bool.new(value: left.value > right.value)
      when :greater_equal
        Lox::Object::Bool.new(value: left.value >= right.value)
      when :less
        Lox::Object::Bool.new(value: left.value < right.value)
      when :less_equal
        Lox::Object::Bool.new(value: left.value <= right.value)
      when :bang_equal
        Lox::Object::Bool.new(value: !equal?(left, right))
      when :equal_equal
        Lox::Object::Bool.new(value: equal?(left, right))
      else
        error! expr.operator, "Unknown binary operator: #{expr.operator.type}"
      end
    end

    sig { override.params(expr: Expression::Ternary).returns(Lox::Object) }
    def visit_ternary_expr(expr) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      left = evaluate expr.left
      case [expr.left_operator.type, expr.right_operator.type]
      in [:question, :colon]
        if truthy?(left)
          evaluate expr.middle
        else
          evaluate expr.right
        end
      else
        error! expr.left_operator,
               "Unknown ternary operator: #{expr.left_operator.lexeme} #{expr.right_operator.lexeme}"
      end
    end

    sig { params(object: Lox::Object).returns(T::Boolean) }
    def truthy?(object)
      case object
      when Lox::Object::Bool
        object.value
      when Lox::Object::Nil
        false
      else
        true
      end
    end

    sig { params(type: T::Class[Lox::Object], objects: T::Array[Lox::Object], token: Lox::Token).void }
    def check_types(type:, objects:, token:)
      objects.each do |obj|
        error! token, "Operand must be a #{type}" unless obj.is_a?(type)
      end
    end

    sig { params(token: Lox::Token, message: String).returns(T.noreturn) }
    def error!(token, message)
      @process.runtime_error(token.line, message)
      raise Lox::Error::SyntaxError
    end

    sig { params(obj_a: Lox::Object, obj_b: Lox::Object).returns(T::Boolean) }
    def equal?(obj_a, obj_b)
      return true if obj_a.value.nil? && obj_b.value.nil?
      return false if obj_a.value.nil? || obj_b.value.nil?

      obj_a.value == obj_b.value
    end

    sig { params(statements: T.untyped).void }
    def interpret(statements); end

    private

    sig { params(expr: Expression).returns(Lox::Object) }
    def evaluate(expr)
      expr.accept(self)
    end
  end
end
