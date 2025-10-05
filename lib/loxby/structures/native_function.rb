# frozen_string_literal: true

class Lox
  # The `Helpers` module contains
  # various helper modules and classes
  # used throughout loxby.
  module Structures
    # A `NativeFunction` is a loxby function
    # which references a callable Ruby
    # object (block, proc, method, etc.).
    #
    # For example:
    # ```ruby
    # @environment.set(
    #   'clock',
    #   NativeFunction.new(0) do |_interpreter, _args|
    #     Time.now.to_i.to_f
    #   end
    # )
    # ```
    class NativeFunction
      include Lox::Helpers::Callable
      def initialize(given_arity = 0, &block)
        @block = block
        @arity = given_arity
      end

      def call(interpreter, args) = @block.call(interpreter, args)

      def arity
        if @arity.respond_to? :call
          @arity.call
        else
          @arity
        end
      end

      def to_s
        '<native fn>'
      end
    end
  end
end
