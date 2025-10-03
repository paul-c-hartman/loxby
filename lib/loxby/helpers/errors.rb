# frozen_string_literal: true

class Lox
  module Helpers
    module Errors
      # A generic loxby error class raised
      # when a syntax error is found.
      class ParseError < RuntimeError; end

      # A generic loxby error class raised
      # when a runtime error is found.
      class RunError < RuntimeError
        attr_reader :token

        def initialize(token, message)
          super(message)
          @token = token
        end
      end

      # A loxby error class raised when
      # a number is divided by zero.
      class DividedByZeroError < RunError; end
    end
  end
end
