# frozen_string_literal: true
# typed: strict

class Lox
  # An AST `Visitor` which performs semantic
  # analysis to resolve variable
  # references in a single pass.
  class Resolver
    extend T::Sig

    sig { params(tree: T.untyped, process: Lox).void }
    def initialize(tree, process)
      @tree = tree
      @process = process
      @interpreter = T.let(process.interpreter, Lox::Interpreter)
    end

    sig { params(statements: T.untyped).returns(T.untyped) }
    def resolve(statements)
    end

    alias process resolve
  end
end
