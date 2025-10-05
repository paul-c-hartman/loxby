# frozen_string_literal: true

class Lox
  module Helpers
    # The interface for callable objects
    # in loxby. Currently just functions.
    #
    # To mark a class as callable, simply
    # `include Lox::Helpers::Callable`.
    module Callable
      def call(_interpreter, _arguments)
        raise NotImplementedError, "#{self.class} has not implemented #call"
      end

      def arity
        raise NotImplementedError, "#{self.class} has not implemented #arity"
      end
    end
  end
end
