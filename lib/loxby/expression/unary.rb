# frozen_string_literal: true
# typed: strict

class Lox
  module Expression
    # Represents a unary operation expression.
    # Props: operator (Token), right (Expression)
    class Unary < T::Struct
      include Expression
      extend T::Sig

      prop :operator, Token
      prop :right, Expression

      sig { override.params(visitor: Lox::Visitor).returns(T.untyped) }
      def accept(visitor) = visitor.visit_unary_expr(self)
    end
  end
end
