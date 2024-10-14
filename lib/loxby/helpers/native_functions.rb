# frozen_string_literal: true

require_relative '../interpreter'
require_relative 'callable'
require_relative '../visitors/base'

class Interpreter < Visitor # rubocop:disable Style/Documentation
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
    include Lox::Callable
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

  # Native extension interface for Loxby.
  #
  # For example, to extend the base
  # interpreter directly:
  #
  # ```ruby
  # require 'loxby/interpreter'
  # require 'loxby/helpers/native_functions'
  # Interpreter.native_function(:greet, arity: 1) { |_interpreter, args| puts "Hello #{args[0]}!" }
  # ```
  #
  # Or inside a modified interpreter:
  # ```ruby
  # require 'loxby/interpreter'
  # require 'loxby/helpers/native_functions'
  # class MyInterpreter < Interpreter
  #   ...
  #   native_function :greet, arity: 1, &->(_interpreter, args) { puts "Hello #{args[0]}!" }
  # end
  # ```
  def self.native_function(name, arity:, &block)
    Lox.native_functions << { name:, arity:, block: }
  end

  def define_native_functions
    Lox.native_functions.each do |func|
      @globals.set func[:name].to_s, NativeFunction.new(func[:arity], &func[:block])
    end
  end

  native_function :clock, arity: 0, &->(_int, _args) { Time.now.to_i.to_f }
  native_function :exit, arity: 0, &->(_int, _args) { throw :lox_exit }
end
