# frozen_string_literal: true
# typed: strict

class Lox
  module Object
    # `Lox::Object::Num` represents integer and float literal values in Lox.
    class Num < T::Struct
      include Lox::Object
      extend T::Sig

      const :value, T.any(Integer, Float)

      sig { override.returns(::String) }
      def to_s
        @value.to_s
      end

      sig { override.returns(T.any(Integer, Float)) }
      attr_reader :value
    end
  end
end
