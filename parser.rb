require_relative 'loxby'
require_relative 'ast'
require_relative 'token_type'
require_relative 'errors'

class Lox
  class Parser
    def initialize(tokens, interpreter)
      @tokens = tokens
      @interpreter = interpreter
      # Variables for parsing
      @current = 0
    end

    def parse
      expression_list
    rescue Lox::ParseError => e
      nil
    end

    def expression_list
      expr = conditional

      while matches? :comma
        operator = previous
        right = conditional
        expr = Lox::AST::Expression::Binary.new(left: expr, operator:, right:)
      end
      
      expr
    end

    # Ternary operator
    def conditional
      expr = expression

      if matches? :question
        left_operator = previous
        center = expression_list
        consume :colon, "Expect ':' after '?' (ternary operator)."
        right_operator = previous
        right = conditional # Recurse, right-associative
        expr = Lox::AST::Expression::Ternary.new(left: expr, left_operator:, center:, right_operator:, right:)
      end

      expr
    end

    def expression
      equality
    end

    def equality
      expr = comparison
      while matches?(:bang_equal, :equal_equal)
        operator = previous
        right = comparison
        # Compose (equality is left-associative)
        expr = Lox::AST::Expression::Binary.new(left: expr, operator:, right:)
      end
      expr
    end

    def comparison
      expr = term

      while matches?(:greater, :greater_equal, :less, :less_equal)
        operator = previous
        right = term
        expr = Lox::AST::Expression::Binary.new(left: expr, operator:, right:)
      end

      expr
    end

    def term
      expr = factor

      while matches?(:minus, :plus)
        operator = previous
        right = factor
        expr = Lox::AST::Expression::Binary.new(left: expr, operator:, right:)
      end

      expr
    end

    def factor
      expr = unary
      
      while matches?(:slash, :star)
        operator = previous
        right = unary
        expr = Lox::AST::Expression::Binary.new(left: expr, operator:, right:)
      end

      expr
    end

    def unary
      # Unary operators are right-associative, so we match
      # first, then recurse.
      if matches?(:bang, :minus)
        operator = previous
        right = unary

        Lox::AST::Expression::Unary.new(operator:, right:)
      else
        primary
      end
    end

    def primary
      if matches? :false
        Lox::AST::Expression::Literal.new(value: false)
      elsif matches? :true
        Lox::AST::Expression::Literal.new(value: true)
      elsif matches? :nil
        Lox::AST::Expression::Literal.new(value: nil)
      elsif matches? :number, :string
        Lox::AST::Expression::Literal.new(value: previous.literal)
      elsif matches? :left_paren
        expr = expression_list
        consume :right_paren, "Expect ')' after expression."
        Lox::AST::Expression::Grouping.new(expression: expr)
      else
        raise error(peek, "Expect expression.")
      end
    end

    private
    
    def consume(type, message)
      return advance if check(type)

      # Call #error to report the error to the interpreter, and
      # raise the error in prep for synchronizing (panic mode).
      raise error(peek, message)
    end

    def error(token, message)
      @interpreter.error(token, message)
      Lox::ParseError.new
    end

    # Synchronize the parser (i.e. panic mode).
    # We're skipping possibly erroneous tokens
    # to prevent cascading errors.
    def synchronize
      advance

      until end_of_input?
        return if previous.type == :semicolon
        return if peek.type == :return

        advance
      end
    end

    # Checks if current token is a given type, consuming
    # it if it is.
    def matches?(*types)
      # Array#any? guarantees short-circuit evaluation.
      # #advance returns a Token/Expression, which is truthy.
      # `advance if check(type)` is truthy when `check(type)`
      # is.
      types.any? { |type| advance if check(type) }
    end

    # Checks if current token is a given type. Does not
    # consume it.
    def check(type)
      peek.type == type && !end_of_input?
    end

    def advance
      @current += 1 unless end_of_input?
      previous
    end

    def end_of_input?
      peek.type == :eof
    end

    def peek
      @tokens[@current]
    end

    def previous
      @tokens[@current - 1]
    end
  end
end