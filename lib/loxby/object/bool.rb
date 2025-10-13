# frozen_string_literal: true
# typed: strict

class Lox
  module Object
    # `Lox::Object::Bool` represents boolean values in Lox.
    class Bool < T::Struct
      include Lox::Object
      extend T::Sig

      const :value, T::Boolean

      sig { override.returns(::String) }
      def to_s
        @value.to_s
      end

      sig { override.returns(T::Boolean) }
      attr_reader :value
    end
  end
end
