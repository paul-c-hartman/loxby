# frozen_string_literal: true

class Lox
  class ParseError < RuntimeError; end

  class RunError < RuntimeError # rubocop:disable Style/Documentation
    attr_reader :token

    def initialize(token, message)
      super(message)
      @token = token
    end
  end

  class DividedByZeroError < RunError; end
end
