# frozen_string_literal: true
# typed: true

class Lox
  # Configuration for Loxby.
  CONFIG = {
    exit_code: {
      interrupt: 130,
      usage: 64,
      syntax_error: 65,
      runtime_error: 70
    }
  }
end
