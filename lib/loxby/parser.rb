# frozen_string_literal: true
# typed: strict

class Lox
  # `Lox::Parser` converts a list of tokens
  # from `Lox::Scanner` to a syntax tree.
  # This tree can be interacted with using
  # the Visitor pattern.
  class Parser
    extend T::Sig

    sig { params(tokens: T::Array[T.untyped], process: Lox).void }
    def initialize(tokens, process)
      @tokens = tokens
      @process = process
    end

    sig { returns(T::Array[T.untyped]) }
    def parse
      []
    end

    alias process parse
  end
end
