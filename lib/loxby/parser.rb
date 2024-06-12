# frozen_string_literal: true

require_relative 'helpers/ast'
require_relative 'helpers/errors'

class Lox
  # Lox::Parser converts a list of tokens
  # from Lox::Scanner to a syntax tree.
  # This tree can be interacted with using
  # the Visitor pattern. (See the Visitor
  # class in visitors/base.rb.)
  class Parser
    def initialize(tokens, interpreter)
      @tokens = tokens
      @interpreter = interpreter
      # Variables for parsing
      @current = 0
    end

    def parse
      statements = []
      statements << declaration until end_of_input?
      statements
    end

    def declaration
      if matches?(:var)
        var_declaration
      else
        statement
      end
    rescue Lox::ParseError
      synchronize
      nil
    end

    def var_declaration
      name = consume :identifier, 'Expect variable name.'
      initializer = matches?(:equal) ? expression : nil
      consume :semicolon, "Expect ';' after variable declaration."
      Lox::AST::Statement::Var.new(name:, initializer:)
    end

    def statement # rubocop:disable Metrics/MethodLength
      if matches? :if
        if_statement
      elsif matches? :print
        print_statement
      elsif matches? :while
        while_statement
      elsif matches? :left_brace
        Lox::AST::Statement::Block.new(statements: block)
      else
        expression_statement
      end
    end

    def block
      statements = []
      statements << declaration until check(:right_brace) || end_of_input?
      consume :right_brace, "Expect '}' after block."
      statements
    end

    def print_statement
      value = expression_list
      consume :semicolon, "Expect ';' after value."
      Lox::AST::Statement::Print.new(expression: value)
    end

    def if_statement
      consume :left_paren, "Expect '(' after 'if'."
      condition = expression_list
      consume :right_paren, "Expect ')' after if condition."

      # We don't go up to var declaration because variables
      # declared inside an if statement should be inside a
      # *block* inside the if statement.
      then_branch = statement
      else_branch = matches?(:else) ? statement : nil

      Lox::AST::Statement::If.new(condition:, then_branch:, else_branch:)
    end

    def while_statement
      consume :left_paren, "Expect '(' after 'while'."
      condition = expression_list
      consume :right_paren, "Expect ')' after condition."
      body = statement

      Lox::AST::Statement::While.new(condition:, body:)
    end

    def expression_statement
      expr = expression_list
      consume :semicolon, "Expect ';' after expression."
      Lox::AST::Statement::Expression.new(expression: expr)
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
        center = check(:colon) ? Lox::AST::Expression::Literal.new(value: nil) : expression_list
        consume :colon, "Expect ':' after expression (ternary operator)."
        right_operator = previous
        right = conditional # Recurse, right-associative
        expr = Lox::AST::Expression::Ternary.new(left: expr, left_operator:, center:, right_operator:, right:)
      end

      expr
    end

    def expression
      assignment
    end

    def assignment # rubocop:disable Metrics/MethodLength
      expr = logical_or

      if matches? :equal
        equals = previous
        value = assignment

        if expr.is_a? Lox::AST::Expression::Variable
          name = expr.name
          return Lox::AST::Expression::Assign.new(name:, value:)
        end

        error equals, 'Invalid assignment target.'
      end

      expr
    end

    def logical_or
      expr = logical_and

      while matches? :or
        operator = previous
        right = logical_and
        expr = Lox::AST::Expression::Logical.new(left: expr, operator:, right:)
      end

      expr
    end

    def logical_and
      expr = equality

      while matches? :and
        operator = previous
        right = logical_and
        expr = Lox::AST::Expression::Logical.new(left: expr, operator:, right:)
      end

      expr
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

    def primary # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      if matches? :false
        Lox::AST::Expression::Literal.new(value: false)
      elsif matches? :true
        Lox::AST::Expression::Literal.new(value: true)
      elsif matches? :nil
        Lox::AST::Expression::Literal.new(value: nil)
      elsif matches? :number, :string
        Lox::AST::Expression::Literal.new(value: previous.literal)
      elsif matches? :identifier
        Lox::AST::Expression::Variable.new(name: previous)
      elsif matches? :left_paren
        expr = expression_list
        consume :right_paren, "Expect ')' after expression."
        Lox::AST::Expression::Grouping.new(expression: expr)
      # Error productions--binary operator without left operand
      elsif matches? :comma
        err = error(previous, "Expect expression before ',' operator.")
        conditional # Parse and throw away
        raise err
      elsif matches? :question
        err = error(previous, 'Expect expression before ternary operator.')
        expression_list
        consume :colon, "Expect ':' after '?' (ternary operator)."
        conditional
        raise err
      elsif matches? :bang_equal, :equal_equal
        err = error(previous, "Expect value before '#{previous.lexeme}'.")
        comparison
        raise err
      elsif matches? :greater, :greater_equal, :less, :less_equal
        err = error(previous, "Expect value before '#{previous.lexeme}'.")
        term
        raise err
      elsif matches? :plus
        err = error(previous, "Expect value before '+'.")
        factor
        raise err
      elsif matches? :slash, :star
        err = error(previous, "Expect value before '#{previous.lexeme}'.")
        unary
        raise err
      # Base case--no match.
      else
        raise error(peek, 'Expect expression.')
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
