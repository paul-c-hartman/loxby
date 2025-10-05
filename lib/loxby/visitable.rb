# frozen_string_literal: true

class Lox
  # Visitable adds `#accept`, the only
  # method required to implement the
  # visitor pattern on a class.
  # To use the visitor pattern,
  # `include Visitable` to your class
  # and subclass `Lox::Visitors::BaseVisitor` to implement
  # visitors.
  module Visitable
    def accept(visitor)
      raise NotImplementedError, "#{self.class} has not implemented #accept"
    end
  end
end
