# frozen_string_literal: true
# typed: strict

class Lox
  # `Lox::Expression` is the base class for all
  # expressions in Lox. It is not instantiated
  # directly.
  module Expression
    extend T::Sig
    extend T::Helpers

    ValueType = T.type_alias { T.any(String, Float, Integer, TrueClass, FalseClass, NilClass) }

    interface!

    sig { abstract.params(visitor: Lox::Visitor).returns(T.untyped) }
    def accept(visitor); end
  end
end
