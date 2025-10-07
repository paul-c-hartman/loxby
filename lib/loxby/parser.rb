# frozen_string_literal: true
# typed: true

class Lox
  # `Lox::Parser` converts a list of tokens
  # from `Lox::Scanner` to a syntax tree.
  # This tree can be interacted with using
  # the Visitor pattern.
  class Parser
    def initialize(tokens, interpreter)
      @tokens = tokens
      @interpreter = interpreter
    end

    def parse; end

    alias process parse
  end
end
