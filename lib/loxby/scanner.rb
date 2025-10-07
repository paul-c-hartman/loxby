# frozen_string_literal: true
# typed: strict

class Lox
  # `Lox::Scanner` converts a string to
  # a series of tokens using a giant
  # `case` statement.
  class Scanner
    extend T::Sig

    sig { params(source: String, process: Lox).void }
    def initialize(source, process)
      @source = source
      @process = process
    end

    sig { returns(T.untyped) }
    def scan; end

    alias process scan
  end
end
