# frozen_string_literal: true

require_relative '../loxby'

class Lox
  # Lox::Runner is the interactive runner
  # which kickstarts the interpreter.
  # An instance is created when loxby is
  # initialized from the command line.
  class Runner
    def initialize(out = $stdout, err = $stderr)
      trap('SIGINT') { exit } # Exit cleanly on Ctrl-C
      @interpreter = Lox.new
      @out = out
      @err = err
    end

    def run(args)
      if args.size > 1
        @out.puts 'Usage: loxby.rb [script]'
        exit 64
      elsif args.size == 1
        @interpreter.run_file args[0]
      else
        @interpreter.run_prompt # Run interactively
      end
    end
  end
end
