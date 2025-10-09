# frozen_string_literal: true
# typed: strict

class Lox
  module Expression
    # Represents a binary operation expression.
    # Props: left (Expression), operator (Lox::Token), right (Expression)
    class Binary < T::Struct
      include Lox::Expression
      extend T::Sig

      prop :left, Expression
      prop :operator, Lox::Token
      prop :right, Expression

      sig { override.params(visitor: Lox::Visitor).returns(T.untyped) }
      def accept(visitor) = visitor.visit_binary_expr(self)
    end
  end
end
