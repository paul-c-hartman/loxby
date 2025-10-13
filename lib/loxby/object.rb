# frozen_string_literal: true
# typed: strict

class Lox
  # `Lox::Object` is the interface for all Lox objects.
  module Object
    include Kernel
    extend T::Sig
    extend T::Helpers

    interface!

    sig { abstract.returns(::String) }
    def to_s; end

    sig { abstract.returns(T.untyped) }
    def value; end
  end
end
