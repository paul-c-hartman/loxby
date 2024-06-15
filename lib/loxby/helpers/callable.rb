# frozen_string_literal: true

class Lox
  module Callable
    def call(_interpreter, _arguments)
      raise NotImplementedError, "#{self.class} has not implemented #call"
    end

    def arity
      raise NotImplementedError, "#{self.class} has not implemented #arity"
    end
  end
end
