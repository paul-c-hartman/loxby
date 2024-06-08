require_relative 'loxby'

class Lox
  class Environment
    def initialize
      @values = {}
    end

    def []=(name, value)
      @values[name.lexeme] = value
    end

    def [](name)
      if @values.keys.member? name.lexeme
        @values[name.lexeme]
      else
        raise Lox::RunError.new(name, "Undefined variable '#{name.lexeme}'")
      end
    end
  end
end