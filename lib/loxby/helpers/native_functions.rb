# frozen_string_literal: true

require_relative '../interpreter'
require_relative 'callable'
require_relative '../visitors/base'

class Interpreter < Visitor
  class NativeFunction
    include Lox::Callable
    def initialize(given_arity = 0, &block)
      @block = block
      @arity = given_arity
    end

    def call(interpreter, args) = @block.call(interpreter:, args:)

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

  def define_native_functions
    @globals.set 'clock', NativeFunction.new(0) do |_interpreter:, _args:|
      Time.now.to_i # Seconds since Epoch
    end
  end
end
