# frozen_string_literal: true

require_relative '../loxby'
require_relative 'config'

class Lox
  # `Lox::Runner` is the interactive runner
  # which kickstarts the interpreter.
  # An instance is created when loxby is
  # initialized from the command line,
  # though it can be instantiated from
  # code as well.
  class Runner
    def initialize(out = $stdout, err = $stderr)
      # Exit cleanly. 130 is for interrupted scripts
      trap('INT') do
        puts
        exit Lox.config.exit_code.interrupt
      end

      @interpreter = Lox.new
      @out = out
      @err = err
    end

    def run(args)
      if args.size > 1
        @out.puts 'Usage: loxby [script]'
        exit Lox.config.exit_code.usage
      elsif args.size == 1
        @interpreter.run_file args[0]
      else
        @interpreter.run_prompt # Run interactively
      end
    end
  end
end
