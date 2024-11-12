# frozen_string_literal: true

require_relative 'errors'

class Lox
  # Stores namespaces for a Lox interpreter.
  # Environments can be nested (for scope).
  class Environment
    attr_reader :enclosing, :values

    def initialize(enclosing = nil)
      @enclosing = enclosing
      @values = {}
    end

    def undefined_variable(name)
      Lox::RunError.new(name, "Undefined variable '#{name.lexeme}'")
    end

    def []=(name, value)
      set name.lexeme, value
    end

    # Used to set a static association. For example:
    #   env.set 'static_function_name', static_function
    def set(name, value)
      @values[name] = value
    end

    def declared?(name)
      # We can't check for a dummy value
      # since loxby uses `nil` as well
      @values.keys.member? name.lexeme
    end

    def get_at(distance, name)
      ancestor(distance).values[name]
    end

    def assign_at(distance, name, value)
      ancestor(distance).values[name] = value
    end

    def [](name)
      if @values[name.lexeme]
        @values[name.lexeme]
      elsif declared? name
        raise Lox::RunError.new(name, "Declared variable not initialized: '#{name.lexeme}'")
      elsif @enclosing
        @enclosing[name]
      else
        raise undefined_variable(name)
      end
    end

    def ancestor(distance)
      env = self
      distance.times { env = env.enclosing }
      env
    end

    def assign(name, value)
      if declared? name
        self[name] = value
      elsif @enclosing
        @enclosing.assign(name, value)
      else
        raise undefined_variable(name)
      end
    end

    alias define []=
  end
end
