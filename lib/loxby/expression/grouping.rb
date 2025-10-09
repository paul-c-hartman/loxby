# frozen_string_literal: true
# typed: strict

class Lox
  module Expression
    # Represents a grouping operation expression.
    # Props: expression (Expression)
    class Grouping < T::Struct
      include Lox::Expression
      extend T::Sig

      prop :expression, Expression

      sig { override.params(visitor: Lox::Visitor).returns(T.untyped) }
      def accept(visitor) = visitor.visit_grouping_expr(self)
    end
  end
end
