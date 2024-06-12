# frozen_string_literal: true

class Lox
  class Token
    TOKENS = [
      # Single-character tokens.
      :left_paren, :right_paren, :left_brace, :right_brace,
      :comma, :dot, :minus, :plus, :semicolon, :slash, :star,
      :question, :colon,

      # 1-2 character tokens.
      :bang, :bang_equal,
      :equal, :equal_equal,
      :greater, :greater_equal,
      :less, :less_equal,

      # Literals.
      :identifier, :string, :number,

      # Keywords.
      :and, :class, :else, :false, :fun, :for, :if, :nil, :or,
      :print, :return, :super, :this, :true, :var, :while,

      :eof
    ].freeze
    SINGLE_TOKENS = TOKENS.zip('(){},.-+;/*'.split('')).to_h

    attr_reader :type, :lexeme, :literal, :line

    def initialize(type, lexeme, literal, line)
      @type = type
      @lexeme = lexeme
      @literal = literal
      @line = line
    end

    def to_s = "#{type} #{lexeme} #{literal}"
    def inspect = "#<Lox::Token #{self}>"
  end
end
