# frozen_string_literal: true
# typed: strict

class Lox
  # TokenType is an enumeration of all
  # the different types of tokens that
  # the scanner can produce.
  TokenType = [ # rubocop:disable Naming/ConstantName
    # // Single-character tokens.
    :left_paren, :right_paren, :left_brace, :right_brace,
    :comma, :dot, :minus, :plus, :semicolon, :slash, :star,

    # // One or two character tokens.
    :bang, :bang_equal,
    :equal, :equal_equal,
    :greater, :greater_equal,
    :less, :less_equal,

    # // Literals.
    :identifier, :string, :number,

    # // Keywords.
    :and, :class, :else, :false, :fun, :for, :if, :nil, :or,
    :print, :return, :super, :this, :true, :var, :while,

    :comment, :multiline_comment, :eof
  ].freeze
end
