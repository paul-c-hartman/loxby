# frozen_string_literal: true

require_relative 'errors'

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
      set name.lexeme, value
    end

    # Used to set a static association. For example:
    #   env.set 'static_function_name', static_function
    def set(name, value)
      @values[name] = value
    end

    def exists?(name)
      @values.keys.member? name.lexeme
    end

    def [](name)
      if @values[name.lexeme]
        @values[name.lexeme]
      elsif exists? name
        raise Lox::RunError.new(name, "Declared variable not initialized: '#{name.lexeme}'")
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

    alias define []=
  end
end
