# frozen_string_literal: true
# typed: strict

class Lox
  # `Lox::Parser` converts a list of tokens
  # from `Lox::Scanner` to a syntax tree.
  # This tree can be interacted with using
  # the Visitor pattern.
  class Parser
    extend T::Sig

    sig { params(tokens: T::Array[Lox::Token], process: Lox).void }
    def initialize(tokens, process)
      @tokens = tokens
      @process = process
      @current = T.let(0, Integer)
    end

    sig { returns(T.nilable(Lox::Expression)) }
    def parse
      expression
    rescue Lox::Error::ParseError
      nil
    end

    sig { returns(Lox::Expression) }
    def expression
      expression_list
    end

    sig { returns(Lox::Expression) }
    def expression_list
      expr = ternary
      while matches? :comma
        operator = previous
        right = ternary
        expr = Lox::Expression::Binary.new(left: expr, operator:, right:)
      end
      expr
    end

    sig { returns(Lox::Expression) }
    def ternary
      expr = equality
      if matches? :question
        left_operator = previous
        middle = equality
        consume(:colon, "Expect ':' after expression.")
        right_operator = previous
        right = ternary
        return Lox::Expression::Ternary.new(left: expr, left_operator:, middle:, right_operator:, right:)
      end
      expr
    end

    sig { returns(Lox::Expression) }
    def equality
      expr = comparison

      while matches? :bang, :bang_equal
        operator = previous
        right = comparison
        expr = Lox::Expression::Binary.new(left: expr, operator:, right:)
      end

      expr
    end

    sig { returns(Lox::Expression) }
    def comparison
      expr = term

      while matches? :less, :less_equal, :greater, :greater_equal
        operator = previous
        right = term
        expr = Lox::Expression::Binary.new(left: expr, operator:, right:)
      end

      expr
    end

    sig { returns(Lox::Expression) }
    def term
      expr = factor

      while matches? :plus, :minus
        operator = previous
        right = factor
        expr = Lox::Expression::Binary.new(left: expr, operator:, right:)
      end

      expr
    end

    sig { returns(Lox::Expression) }
    def factor
      expr = unary

      while matches? :star, :slash
        operator = previous
        right = unary
        expr = Lox::Expression::Binary.new(left: expr, operator:, right:)
      end

      expr
    end

    sig { returns(Lox::Expression) }
    def unary
      if matches? :minus, :bang
        operator = previous
        right = primary
        return Lox::Expression::Unary.new(operator:, right:)
      end

      primary
    end

    private

    sig { returns(Lox::Expression) }
    def primary # rubocop:disable Metrics/MethodLength
      if matches? :true
        return Lox::Expression::Literal.new(value: true)
      elsif matches? :false
        return Lox::Expression::Literal.new(value: false)
      elsif matches? :nil
        return Lox::Expression::Literal.new(value: nil)
      elsif matches? :number, :string
        return Lox::Expression::Literal.new(value: previous.literal)
      elsif matches? :left_paren
        expr = expression
        consume(:right_paren, "Expect ')' after expression.")
        return Lox::Expression::Grouping.new(expression: expr)
      elsif matches? :comma
        ternary # Throw away right-hand side for error recovery
        error! previous, "Expect expression before ','."
      elsif matches? :question, :colon
        # Throw away right-hand side for error recovery
        equality
        consume :colon, "Expect ':' after expression."
        ternary
        error! previous, "Expect expression before '?'."
      elsif matches? :bang, :bang_equal
        operator = previous.lexeme
        comparison # Throw away right-hand side for error recovery
        error! previous, "Expect expression before '#{operator}'."
      elsif matches? :less, :less_equal, :greater, :greater_equal
        operator = previous.lexeme
        term # Throw away right-hand side for error recovery
        error! previous, "Expect expression before '#{operator}'."
      elsif matches? :plus, :minus
        operator = previous.lexeme
        factor # Throw away right-hand side for error recovery
        error! previous, "Expect expression before '#{operator}'."
      elsif matches? :star, :slash
        operator = previous.lexeme
        unary # Throw away right-hand side for error recovery
        error! previous, "Expect expression before '#{operator}'."
      end

      error! peek, 'Expect expression.'
    end

    sig { params(types: Symbol).returns(T::Boolean) }
    def matches?(*types)
      types.each do |type|
        if check(type)
          advance
          return true
        end
      end
      false
    end

    sig { params(type: Symbol, message: String).returns(Lox::Token) }
    def consume(type, message)
      return advance if check(type)

      error! peek, message
    end

    sig { params(type: Symbol).returns(T::Boolean) }
    def check(type)
      return false if eof?

      peek.type == type
    end

    sig { returns(Lox::Token) }
    def advance
      @current += 1 unless eof?
      previous
    end

    sig { returns(T::Boolean) }
    def eof?
      peek.type == :eof
    end

    sig { returns(Lox::Token) }
    def peek = T.must(@tokens[@current])

    sig { returns(Lox::Token) }
    def previous = T.must(@tokens[@current - 1])

    sig { params(token: Lox::Token, message: String).returns(T.noreturn) }
    def error!(token, message)
      @process.error(token.line, message)
      raise Lox::Error::ParseError
    end

    sig { void }
    def synchronize
      advance

      until eof?
        return if previous.type == :semicolon

        case peek.type
        when :return
          return
        end

        advance
      end
    end

    alias process parse
  end
end
