# frozen_string_literal: true
# typed: true

class Lox
  # `Lox::Scanner` converts a string to
  # a series of tokens using a giant
  # `case` statement.
  class Scanner
    def initialize(source, interpreter)
      @source = source
      @interpreter = interpreter
    end

    def scan; end

    alias process scan
  end
end
