# frozen_string_literal: true

require_relative 'loxby'

class Lox
  # Lox::Environment stores namespace for
  # a Lox interpreter. Environments can be
  # nested (for scope).
  class Environment
    def initialize(enclosing = nil)
      @enclosing = enclosing
      @values = {}
    end

    def undefined_variable
      Lox::RunError.new(name, "Undefined variable '#{name.lexeme}'")
    end

    def []=(name, value)
      @values[name.lexeme] = value
    end

    def [](name)
      if @values.keys.member? name.lexeme
        @values[name.lexeme]
      elsif @enclosing
        @enclosing[name]
      else
        raise undefined_variable
      end
    end

    def assign(name, value)
      if self[name]
        self[name] = value
      elsif @enclosing
        @enclosing.assign(name, value)
      else
        raise undefined_variable
      end
    end
  end
end
