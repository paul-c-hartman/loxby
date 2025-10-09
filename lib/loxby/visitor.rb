# frozen_string_literal: true
# typed: strict

class Lox
  # Visitor is the interface for the Visitor pattern.
  module Visitor
    extend T::Sig
    extend T::Helpers

    interface!

    sig { abstract.params(expr: Expression::Binary).returns(T.untyped) }
    def visit_binary_expr(expr); end

    sig { abstract.params(expr: Expression::Grouping).returns(T.untyped) }
    def visit_grouping_expr(expr); end

    sig { abstract.params(expr: Expression::Literal).returns(T.untyped) }
    def visit_literal_expr(expr); end

    sig { abstract.params(expr: Expression::Ternary).returns(T.untyped) }
    def visit_ternary_expr(expr); end

    sig { abstract.params(expr: Expression::Unary).returns(T.untyped) }
    def visit_unary_expr(expr); end
  end
end
