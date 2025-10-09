# frozen_string_literal: true
# typed: strict

class Lox
  module Visitor
    # A visitor that prints the AST in a parenthesized format
    # for easier debugging.
    class AstPrinter
      extend T::Sig
      include Visitor

      sig { params(expr: Expression).returns(String) }
      def print(expr)
        expr.accept(self)
      end

      sig { override.params(expr: Expression::Binary).returns(String) }
      def visit_binary_expr(expr)
        parenthesize(expr.operator.lexeme, expr.left, expr.right)
      end

      sig { override.params(expr: Expression::Grouping).returns(String) }
      def visit_grouping_expr(expr)
        parenthesize('group', expr.expression)
      end

      sig { override.params(expr: Expression::Literal).returns(String) }
      def visit_literal_expr(expr)
        expr.value.nil? ? 'nil' : expr.value.to_s
      end

      sig { override.params(expr: Expression::Ternary).returns(String) }
      def visit_ternary_expr(expr)
        parenthesize('?:', expr.left, expr.middle, expr.right)
      end

      sig { override.params(expr: Expression::Unary).returns(String) }
      def visit_unary_expr(expr)
        parenthesize(expr.operator.lexeme, expr.right)
      end

      private

      sig { params(name: String, exprs: Expression).returns(String) }
      def parenthesize(name, *exprs)
        parts = ["(#{name}"]
        exprs.each do |expr|
          parts << ' ' << expr.accept(self)
        end
        parts << ')'
        parts.join
      end
    end
  end
end
