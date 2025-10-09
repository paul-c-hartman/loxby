# frozen_string_literal: true
# typed: strict

class Lox
  class Expression
    # Represents a literal value expression.
    # Props: value (any)
    class Literal < T::Struct
      extend T::Sig

      prop :value, Lox::Expression::ValueType

      sig { params(value: Lox::Expression::ValueType).void }
      def initialize(value:) # rubocop:disable Lint/UselessMethodDefinition
        super(value:)
      end

      sig { params(visitor: Lox::Visitor).returns(Lox::Expression::ValueType) }
      def accept(visitor) = visitor.visit_literal_expr(self)
    end
  end
end
