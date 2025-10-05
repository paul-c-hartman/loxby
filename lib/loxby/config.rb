# frozen_string_literal: true

require 'dry-configurable'

class Lox
  # Configuration for Loxby.
  # Uses dry-configurable gem.
  module Config
    extend Dry::Configurable

    setting :exit_code do
      setting :interrupt, default: 130
      setting :usage, default: 64
      setting :syntax_error, default: 65
      setting :runtime_error, default: 70
    end
  end
end
