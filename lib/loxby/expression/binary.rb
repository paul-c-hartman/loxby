# frozen_string_literal: true
# typed: strict

class Lox
  class Expression
    # Represents a binary operation expression.
    # Props: left (Expression), operator (Lox::Token), right (Expression)
    class Binary < T::Struct
      extend T::Sig

      prop :left, Expression
      prop :operator, Lox::Token
      prop :right, Expression

      sig { params(left: Expression, operator: Lox::Token, right: Expression).void }
      def initialize(left:, operator:, right:)
        super(left:, operator:, right:)
      end

      sig { params(visitor: Lox::Visitor).returns(T.untyped) }
      def accept(visitor) = visitor.visit_binary_expr(self)
    end
  end
end
