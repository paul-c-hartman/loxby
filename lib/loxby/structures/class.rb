# frozen_string_literal: true

class Lox
  module Structures
    # Represents a class in Lox.
    class Class
      include Lox::Helpers::Callable
      attr_reader :name, :methods

      def initialize(name, methods = {})
        @name = name
        @methods = methods
      end

      def call(_interpreter, _arguments)
        # Create a new instance of this class
        Lox::Structures::Instance.new(self)
      end

      def find_method(name)
        methods[name]
      end

      def arity = 0

      def to_s
        "<class #{@name}>"
      end
    end
  end
end
