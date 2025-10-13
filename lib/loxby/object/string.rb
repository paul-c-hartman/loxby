# frozen_string_literal: true
# typed: strict

class Lox
  module Object
    # `Lox::Object::String` represents string literal values in Lox.
    class String < T::Struct
      include Lox::Object
      extend T::Sig

      const :value, ::String

      sig { override.returns(::String) }
      def to_s
        @value
      end

      sig { override.returns(::String) }
      attr_reader :value
    end
  end
end
