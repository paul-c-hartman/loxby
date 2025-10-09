# frozen_string_literal: true
# typed: strict

class Lox
  module Expression
    # Represents a literal value expression.
    # Props: value (any)
    class Literal < T::Struct
      include Expression
      extend T::Sig

      prop :value, Lox::Expression::ValueType

      sig { override.params(visitor: Lox::Visitor).returns(Lox::Expression::ValueType) }
      def accept(visitor) = visitor.visit_literal_expr(self)
    end
  end
end
