# frozen_string_literal: true

require_relative 'callable'
require_relative 'environment'
require_relative '../interpreter'

class Lox
  class Function
    include Callable
    attr_reader :declaration, :enclosure

    def initialize(declaration, closure)
      @declaration = declaration
      @closure = closure
    end

    def call(interpreter, args)
      env = Environment.new(@closure)
      @declaration.params.zip(args).each do |param, arg|
        env[param] = arg # Environment grabs the lexeme automatically
      end

      # Interpreter will `throw :return, return_value` to unwind
      # callstack. We implicitly return that value.
      catch(:return) do
        interpreter.execute_block @declaration.body, env
        # If we get here, there was no return statement.
        return nil
      end
    end

    def arity = @declaration.params.size
    def to_s = "<fn #{@declaration.name ? @declaration.name.lexeme : '(anonymous)'}>"
  end
end
