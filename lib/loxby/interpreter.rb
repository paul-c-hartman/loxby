# frozen_string_literal: true
# typed: strict

class Lox
  # Interpreter class. Walks the AST using
  # the Visitor pattern.
  class Interpreter
    extend T::Sig

    sig { params(process: Lox).void }
    def initialize(process)
      @process = process
    end

    sig { params(statements: T.untyped).void }
    def interpret(statements); end
  end
end
