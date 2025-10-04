# frozen_string_literal: true

class Lox
  # `Lox::Parser` converts a list of tokens
  # from `Lox::Scanner` to a syntax tree.
  # This tree can be interacted with using
  # the Visitor pattern. (See `Lox::Visitors::BaseVisitor`
  # in lib/visitors/base_visitor.rb.)
  class Parser
    def initialize(tokens, interpreter)
      @tokens = tokens
      @interpreter = interpreter
      # Variables for parsing
      @current = 0
    end

    def parse
      @statements = []
      @statements << declaration until end_of_input?
      @statements
    end

    def declaration # rubocop:disable Metrics/MethodLength
      if matches? :fun
        function 'function'
        # primary
      elsif matches? :var
        var_declaration
      elsif check :semicolon
        # Yay edge cases! Either there's an extra semicolon or
        # someone put a function definition in an expression statement.
        # Which is valid (though look at this gross surgery to get it
        # to work) while extra semicolons are not.
        if @statements[-1].is_a? Lox::Helpers::AST::Statement::Function
          advance
          Lox::Helpers::AST::Statement::Expression.new(expression: @statements.pop)
        end

        # If it's not a function-in-expression-statement, control flow
        # calls `statement`, which errors as intended.
      else
        statement
      end
    rescue Lox::Helpers::Errors::ParseError
      synchronize
      nil
    end

    def function(kind) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      name = if check :identifier
               # Named function
               consume :identifier, "Expect #{kind} name."
             else
               Lox::Helpers::Token.new(:identifier, '(anonymous)', '(anonymous)', peek.line)
             end
      consume :left_paren, "Expect '(' after #{kind} name."
      parameters = []
      loop do
        break if check :right_paren

        # This is mostly arbitrary but it keeps execution time down
        error(peek, "Can't have more than 255 parameters.") if parameters.size > 255

        parameters << consume(:identifier, 'Expect parameter name.')
        break unless matches? :comma
      end
      consume :right_paren, "Expect ')' after parameters."

      # Have to consume the first part of the block since
      # it assumes it's already been matched
      consume :left_brace, 'Expect block after parameter list.'
      body = block

      Lox::Helpers::AST::Statement::Function.new(name:, params: parameters, body:)
    end

    def var_declaration
      name = consume :identifier, 'Expect variable name.'
      initializer = matches?(:equal) ? expression : nil
      consume :semicolon, "Expect ';' after variable declaration."
      Lox::Helpers::AST::Statement::Var.new(name:, initializer:)
    end

    def statement # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      if matches? :for
        for_statement
      elsif matches? :if
        if_statement
      elsif matches? :print
        print_statement
      elsif matches? :return
        return_statement
      elsif matches? :while
        while_statement
      elsif matches? :fun
        function 'function'
      elsif matches? :left_brace
        Lox::Helpers::AST::Statement::Block.new(statements: block)
      else
        expression_statement
      end
    end

    def break_or_declaration
      if matches? :break
        break_statement
      else
        declaration
      end
    end

    def block
      statements = []
      statements << break_or_declaration until check(:right_brace) || end_of_input?
      consume :right_brace, "Expect '}' after block."
      statements
    end

    def print_statement
      value = expression_list
      consume :semicolon, "Expect ';' after value."
      Lox::Helpers::AST::Statement::Print.new(expression: value)
    end

    def return_statement
      keyword = previous
      value = nil
      value = expression unless check :semicolon

      consume :semicolon, "Expect ';' after return value."
      Lox::Helpers::AST::Statement::Return.new(keyword:, value:)
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

      Lox::Helpers::AST::Statement::If.new(condition:, then_branch:, else_branch:)
    end

    def while_statement
      consume :left_paren, "Expect '(' after 'while'."
      condition = expression_list
      consume :right_paren, "Expect ')' after condition."
      body = statement

      Lox::Helpers::AST::Statement::While.new(condition:, body:)
    end

    # `for` loops in loxby are syntactic sugar
    # for `while` loops. Yay!

    def for_statement # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      consume :left_paren, "Expect '(' after 'for'."

      initializer =
        if matches? :semicolon
          nil
        elsif matches? :var
          var_declaration
        else
          expression_statement
        end

      condition = nil
      condition = expression unless check :semicolon
      consume :semicolon, "Expect ';' after loop condition."

      increment = nil
      increment = expression unless check :right_paren
      consume :right_paren, "Expect ')' after for clauses."

      body = statement

      unless increment.nil?
        body = Lox::Helpers::AST::Statement::Block.new(
          statements: [
            body,
            Lox::Helpers::AST::Statement::Expression.new(expression: increment)
          ]
        )
      end

      condition = Lox::Helpers::AST::Expression::Literal.new(value: true) if condition.nil?
      body = Lox::Helpers::AST::Statement::While.new(condition:, body:)

      unless initializer.nil?
        body = Lox::Helpers::AST::Statement::Block.new(
          statements: [
            initializer,
            body
          ]
        )
      end

      body
    end

    def break_statement
      consume :semicolon, "Expect ';' after break."
      Lox::Helpers::AST::Statement::Break.new
    end

    def expression_statement
      expr = expression_list
      consume :semicolon, "Expect ';' after expression."
      Lox::Helpers::AST::Statement::Expression.new(expression: expr)
    end

    def expression_list
      expr = conditional

      while matches? :comma
        operator = previous
        right = conditional
        expr = Lox::Helpers::AST::Expression::Binary.new(left: expr, operator:, right:)
      end

      expr
    end

    # Ternary operator
    def conditional
      expr = expression

      if matches? :question
        left_operator = previous
        center = check(:colon) ? Lox::Helpers::AST::Expression::Literal.new(value: nil) : expression_list
        consume :colon, "Expect ':' after expression: incomplete ternary operator."
        right_operator = previous
        right = conditional # Recurse, right-associative
        expr = Lox::Helpers::AST::Expression::Ternary.new(left: expr, left_operator:, center:, right_operator:, right:)
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

        if expr.is_a? Lox::Helpers::AST::Expression::Variable
          name = expr.name
          return Lox::Helpers::AST::Expression::Assign.new(name:, value:)
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
        expr = Lox::Helpers::AST::Expression::Logical.new(left: expr, operator:, right:)
      end

      expr
    end

    def logical_and
      expr = equality

      while matches? :and
        operator = previous
        right = logical_and
        expr = Lox::Helpers::AST::Expression::Logical.new(left: expr, operator:, right:)
      end

      expr
    end

    def equality
      expr = comparison
      while matches?(:bang_equal, :equal_equal)
        operator = previous
        right = comparison
        # Compose (equality is left-associative)
        expr = Lox::Helpers::AST::Expression::Binary.new(left: expr, operator:, right:)
      end
      expr
    end

    def comparison
      expr = term

      while matches?(:greater, :greater_equal, :less, :less_equal)
        operator = previous
        right = term
        expr = Lox::Helpers::AST::Expression::Binary.new(left: expr, operator:, right:)
      end

      expr
    end

    def term
      expr = factor

      while matches?(:minus, :plus)
        operator = previous
        right = factor
        expr = Lox::Helpers::AST::Expression::Binary.new(left: expr, operator:, right:)
      end

      expr
    end

    def factor
      expr = unary

      while matches?(:slash, :star, :percent)
        operator = previous
        right = unary
        expr = Lox::Helpers::AST::Expression::Binary.new(left: expr, operator:, right:)
      end

      expr
    end

    def unary
      # Unary operators are right-associative, so we match
      # first, then recurse.
      if matches?(:bang, :minus)
        operator = previous
        right = unary

        Lox::Helpers::AST::Expression::Unary.new(operator:, right:)
      else
        function_call
      end
    end

    def function_call
      expr = primary
      loop do
        break unless matches? :left_paren

        expr = finish_call expr
      end
      expr
    end

    def finish_call(callee)
      arguments = []
      unless check :right_paren
        loop do
          error(peek, "Can't have more than 255 arguments.") if arguments.size > 255
          arguments << expression
          break unless matches? :comma
        end
      end
      paren = consume :right_paren, "Expect ')' after arguments."
      Lox::Helpers::AST::Expression::Call.new(callee:, paren:, arguments:)
    end

    def primary # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      if matches? :false
        Lox::Helpers::AST::Expression::Literal.new(value: false)
      elsif matches? :true
        Lox::Helpers::AST::Expression::Literal.new(value: true)
      elsif matches? :nil
        Lox::Helpers::AST::Expression::Literal.new(value: nil)
      elsif matches? :fun
        function 'inline function'
      elsif matches? :number, :string
        Lox::Helpers::AST::Expression::Literal.new(value: previous.literal)
      elsif matches? :break
        raise error(previous, "Invalid 'break' not in loop.")
      elsif matches? :identifier
        Lox::Helpers::AST::Expression::Variable.new(name: previous)
      elsif matches? :left_paren
        expr = expression_list
        consume :right_paren, "Expect ')' after expression."
        Lox::Helpers::AST::Expression::Grouping.new(expression: expr)
      # Error productions--binary operator without left operand
      elsif matches? :comma
        err = error(previous, "Expect expression before ',' operator.")
        conditional # Parse and throw away
        raise err
      elsif matches? :question
        err = error(previous, 'Expect expression before ternary operator.')
        # Parse and throw away
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
      Lox::Helpers::Errors::ParseError.new
    end

    # Synchronize the parser (i.e. panic mode).
    # We're skipping possibly erroneous tokens
    # to prevent cascading errors.
    def synchronize
      # @interpreter.out.puts 'entered panic mode'
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
