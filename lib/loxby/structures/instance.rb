# frozen_string_literal: true

class Lox
  module Structures
    # Represents an instance of a Lox class.
    class Instance
      attr_reader :klass, :fields

      def initialize(klass)
        @klass = klass
        @fields = {}
      end

      def get(name)
        return fields[name.lexeme] if fields.key? name.lexeme

        method = klass.find_method(name.lexeme)
        return method.bind(self) if method

        raise Lox::Helpers::Errors::RunError, "Undefined property '#{name.lexeme}'."
      end

      def set(name, value)
        fields[name.lexeme] = value
      end

      def to_s
        "<instance of #{klass.name}>"
      end
    end
  end
end
