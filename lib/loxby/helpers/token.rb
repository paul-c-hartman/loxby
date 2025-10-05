# frozen_string_literal: true

class Lox
  module Helpers
    # A single token. Emitted by
    # `Lox::Scanner` and consumed
    # by `Lox::Parser`.
    class Token
      # List of all token types.
      TOKENS = Lox::Config.config.token_types.tokens

      # Map of single-character token types.
      SINGLE_TOKENS = Lox::Config.config.token_types.single_tokens

      attr_reader :type, :lexeme, :literal, :line

      def initialize(type, lexeme, literal, line)
        @type = type
        @lexeme = lexeme
        @literal = literal
        @line = line
      end

      def to_s = "#{type} #{lexeme} #{literal}"
      def inspect = "#<Lox::Helpers::Token #{self}>"
    end
  end
end
