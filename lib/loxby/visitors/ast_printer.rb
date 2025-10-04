# frozen_string_literal: true

class Lox
  module Visitors
    # This visitor prints a given AST
    # for easier viewing and debugging.
    class ASTPrinter < Lox::Visitors::BaseVisitor
      def print(expression)
        @out.puts expression.accept self
      end

      alias visit print

      def parenthesize(*args)
        str = "(#{args[0]}"
        args[1..].each do |expr|
          str << " #{expr.accept self}"
        end
        str << ')'
      end

      def visit_list(list)
        parenthesize 'list', *list
      end

      def visit_binary_expression(expr)
        parenthesize expr.operator.lexeme, expr.left, expr.right
      end

      def visit_ternary_expression(expr)
        parenthesize expr.left_operator.lexeme + expr.right_operator.lexeme, expr.left, expr.center, expr.right
      end

      def visit_grouping_expression(expr)
        parenthesize 'group', expr.expression
      end

      def visit_literal_expression(expr)
        expr.value.nil? ? 'nil' : expr.value.to_s
      end

      def visit_unary_expression(expr)
        parenthesize expr.operator.lexeme, expr.right
      end

      def visit_assign_expression(expr)
        parenthesize "assign #{expr.name}", expr.value
      end

      def visit_call_expression(expr)
        parenthesize 'call', expr.callee, expr.arguments
      end

      def visit_logical_expression(expr)
        visit_binary_expression(expr)
      end

      def visit_variable_expression(expr)
        "(var #{expr.name})"
      end

      def visit_function_statement(stmt)
        parenthesize "fun #{stmt.name} (#{stmt.params.join ', '})", stmt.body
      end

      def visit_return_statement(stmt)
        parenthesize 'return', stmt.value
      end

      def visit_if_statement(stmt)
        if stmt.else_branch
          parenthesize 'if', stmt.condition, stmt.then_branch, stmt.else_branch
        else
          parenthesize 'if', stmt.condition, stmt.then_branch
        end
      end

      def visit_block_statement(stmt)
        parenthesize 'block', stmt.statements
      end

      def visit_var_statement(stmt)
        if stmt.initializer
          parenthesize "assign #{stmt.name}", stmt.initializer
        else
          parenthesize "assign #{stmt.name}"
        end
      end

      def visit_while_statement(stmt)
        parenthesize 'while', stmt.condition, stmt.body
      end

      def visit_print_statement(stmt)
        parenthesize 'print', stmt.expression
      end

      def visit_expression_statement(stmt)
        stmt.expression.accept(self)
      end
    end
  end
end

# Monkeypatching Array is the wrong approach. Maybe consider creating a custom subclass?
# TokenList/StatementList/something like that?

class Array
  def accept(visitor)
    visitor.visit_list(self)
  end
end
