# frozen_string_literal: true
# typed: strict

class Lox
  class Expression
    # Represents a grouping operation expression.
    # Props: expression (Expression)
    class Grouping < T::Struct
      extend T::Sig

      prop :expression, Expression

      sig { params(expression: Expression).void }
      def initialize(expression:) # rubocop:disable Lint/UselessMethodDefinition
        super(expression:)
      end

      sig { params(visitor: Lox::Visitor).returns(T.untyped) }
      def accept(visitor) = visitor.visit_grouping_expr(self)
    end
  end
end
