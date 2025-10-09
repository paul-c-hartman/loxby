# frozen_string_literal: true
# typed: strict

class Lox
  class Expression
    # Represents a unary operation expression.
    # Props: operator (Token), right (Expression)
    class Unary < T::Struct
      extend T::Sig

      prop :operator, Token
      prop :right, Expression

      sig { params(operator: Token, right: Expression).void }
      def initialize(operator:, right:)
        super(operator:, right:)
      end

      sig { params(visitor: Lox::Visitor).returns(T.untyped) }
      def accept(visitor) = visitor.visit_unary_expr(self)
    end
  end
end
