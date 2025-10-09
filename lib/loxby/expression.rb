# frozen_string_literal: true
# typed: strict

class Lox
  # `Lox::Expression` is the base class for all
  # expressions in Lox. It is not instantiated
  # directly.
  class Expression
    extend T::Sig
    extend T::Helpers

    ValueType = T.type_alias { T.any(String, Float, Integer, TrueClass, FalseClass, NilClass) }

    abstract!

    sig { params(kwargs: T::Hash[Symbol, T.untyped]).void }
    def initialize(**kwargs)
      kwargs.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    sig { abstract.params(visitor: Lox::Visitor).returns(T.untyped) }
    def accept(visitor); end
  end
end
