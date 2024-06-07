#require_relative 'loxby'
# I don't think this is actually required.
# Language-specific implementation details.

Tokens = [
  # Single-character tokens.
  :left_paren, :right_paren, :left_brace, :right_brace,
  :comma, :dot, :minus, :plus, :semicolon, :slash, :star,

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
]

class Lox::Token
  attr_reader :type, :lexeme, :literal, :line
  def initialize(type, lexeme, literal, line)
    @type, @lexeme, @literal, @line = type, lexeme, literal, line
  end

  def to_s = "#{type} #{lexeme} #{literal}"
  def inspect = "#<Lox::Token #{to_s}>"
end