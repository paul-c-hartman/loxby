# frozen_string_literal: true
# typed: strict

class Lox
  module Object
    # `Lox::Object::Nil` represents nil values in Lox.
    class Nil < T::Struct
      include Lox::Object
      extend T::Sig

      sig { override.returns(::String) }
      def to_s
        'nil'
      end

      sig { override.returns(NilClass) }
      def value = nil
    end
  end
end
