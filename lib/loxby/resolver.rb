# frozen_string_literal: true

class Lox
  # An AST `Visitor` which performs semantic
  # analysis to resolve variable
  # references in a single pass.
  class Resolver < Lox::Visitors::BaseVisitor
    attr_reader :scopes, :current_function, :current_class

    def initialize(interpreter) # rubocop:disable Lint/MissingSuper
      @interpreter = interpreter
      @scopes = []
      @current_function = nil
      @current_class = nil
    end

    def resolve(*statements_or_expressions)
      # Visit node
      statements_or_expressions.flatten.each { _1.accept self }
    end

    def resolve_local(expr, name)
      @scopes.each.with_index.reverse_each do |scope, index|
        next unless scope.keys.include? name.lexeme

        depth = @scopes.size - 1 - index
        @interpreter.resolve(expr, depth)
        break
      end
    end

    def resolve_function(func, type:)
      enclosing_function = @current_function
      @current_function = type

      begin_scope
      func.params.each do |param|
        declare param
        define param
      end
      resolve func.body
      end_scope
      @current_function = enclosing_function
    end

    def begin_scope
      @scopes << ({})
    end

    def end_scope
      @scopes.pop
    end

    def declare(name)
      return if @scopes.empty? || name.nil? || name.lexeme.empty?

      scope = @scopes.last
      scope[name.lexeme] = false
    end

    def define(name)
      scope = @scopes.last
      return if @scopes.empty? || scope[name.lexeme].nil?

      scope[name.lexeme] = true
    end

    def visit_block_statement(statement)
      begin_scope
      statement.statements.each { resolve _1 }
      end_scope
    end

    def visit_class_statement(statement) # rubocop:disable Metrics/MethodLength
      enclosing_class = @current_class
      @current_class = :class

      declare statement.name
      define statement.name

      begin_scope
      @scopes.last['this'] = true

      statement.methods.each do |method|
        function_type = :method
        resolve_function method, type: function_type
      end
      end_scope
      @current_class = enclosing_class
    end

    def visit_var_statement(statement)
      declare statement.name
      resolve statement.initializer if statement.initializer
      define statement.name
    end

    def visit_function_statement(statement)
      declare statement.name
      define statement.name

      resolve_function statement, type: :function
    end

    def visit_expression_statement(statement)
      resolve statement.expression
    end

    def visit_if_statement(statement)
      resolve statement.condition
      resolve statement.then_branch
      resolve statement.else_branch if statement.else_branch
    end

    def visit_print_statement(statement)
      resolve statement.expression
    end

    def visit_return_statement(statement)
      @interpreter.process.error(statement.keyword, "Can't return from top-level code.") unless @current_function
      resolve statement.value if statement.value
    end

    def visit_while_statement(statement)
      resolve statement.condition
      resolve statement.body
    end

    def visit_break_statement(_statement); end

    def visit_binary_expression(expr)
      resolve expr.left
      resolve expr.right
    end

    def visit_ternary_expression(expr)
      resolve expr.left
      resolve expr.center
      resolve expr.right
    end

    def visit_call_expression(expr)
      resolve expr.callee
      expr.arguments.each { resolve _1 }
    end

    def visit_get_expression(expr)
      resolve expr.object
    end

    def visit_grouping_expression(expr)
      resolve expr.expression
    end

    def visit_literal_expression(_expr); end

    def visit_logical_expression(expr)
      resolve expr.left
      resolve expr.right
    end

    def visit_set_expression(expr)
      resolve expr.value
      resolve expr.object
    end

    def visit_this_expression(expr)
      unless @current_class
        @interpreter.process.error(expr.keyword, "Can't use 'this' outside of a class.")
        return
      end

      resolve_local(expr, expr.keyword)
    end

    def visit_unary_expression(expr)
      resolve expr.right
    end

    def visit_variable_expression(expr)
      if !@scopes.empty? && @scopes.last[expr.name.lexeme] == false
        @interpreter.process.error(expr.name, "Can't read local variable in its own initializer.")
      end

      resolve_local(expr, expr.name)
    end

    def visit_assign_expression(expr)
      resolve expr.value
      resolve_local(expr, expr.name)
    end
  end
end
