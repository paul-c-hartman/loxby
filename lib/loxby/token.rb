# frozen_string_literal: true
# typed: strict

class Lox
  # A token produced by the scanner.
  class Token
    extend T::Sig

    sig { returns(Symbol) }
    attr_reader :type

    sig { returns(String) }
    attr_reader :lexeme

    sig { returns(T.untyped) }
    attr_reader :literal

    sig { returns(Integer) }
    attr_reader :line

    sig { params(type: Symbol, lexeme: String, literal: T.untyped, line: Integer).void }
    def initialize(type, lexeme, literal, line)
      @type = type
      @lexeme = lexeme
      @literal = literal
      @line = line
    end

    sig { returns(String) }
    def to_s
      "<#{@type}> '#{@lexeme}' #{@literal}"
    end
  end
end
