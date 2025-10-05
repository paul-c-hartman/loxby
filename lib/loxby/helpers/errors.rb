# frozen_string_literal: true

class Lox
  module Helpers
    module Errors
      # The base class for all loxby errors.
      class BaseError < StandardError
        attr_reader :token

        def initialize(token, message)
          super(message)
          @token = token
        end
      end

      # A generic loxby error class raised
      # when a syntax error is found.
      class ParseError < BaseError; end

      # A generic loxby error class raised
      # when a runtime error is found.
      class RunError < BaseError; end

      # A loxby error class raised when
      # a number is divided by zero.
      class DividedByZeroError < RunError; end
    end
  end
end
