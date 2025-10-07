# frozen_string_literal: true
# typed: true

class Lox
  # An AST `Visitor` which performs semantic
  # analysis to resolve variable
  # references in a single pass.
  class Resolver
    def initialize(tree, interpreter)
      @tree = tree
      @interpreter = interpreter
    end

    def resolve; end

    alias process resolve
  end
end
