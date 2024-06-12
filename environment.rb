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

    def undefined_variable(name)
      Lox::RunError.new(name, "Undefined variable '#{name.lexeme}'")
    end

    def []=(name, value)
      @values[name.lexeme] = value
    end

    def exists?(name)
      @values.keys.member? name.lexeme
    end

    def [](name)
      if exists? name
        @values[name.lexeme]
      elsif @enclosing
        @enclosing[name]
      else
        raise undefined_variable(name)
      end
    end

    def assign(name, value)
      if exists? name
        self[name] = value
      elsif @enclosing
        @enclosing.assign(name, value)
      else
        raise undefined_variable(name)
      end
    end
  end
end
