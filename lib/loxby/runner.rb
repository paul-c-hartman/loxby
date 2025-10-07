# frozen_string_literal: true
# typed: strict

class Lox
  # `Lox::Runner` is the interactive runner
  # which kickstarts the interpreter.
  # An instance is created when loxby is
  # initialized from the command line,
  # though it can be instantiated from
  # code as well.
  class Runner
    extend T::Sig

    sig { params(out: IO, err: IO).void }
    def initialize(out = $stdout, err = $stderr)
      # Exit cleanly. 130 is for interrupted scripts
      trap('INT') do
        @out.puts
        exit T.must(Lox::Config.exit_code[:interrupt])
      end

      @out = out
      @err = err
      @process = T.let(Lox.new(@out, @err), Lox)
    end

    sig { params(args: T::Array[String]).void }
    def run(args)
      if args.size > 1
        @out.puts 'Usage: loxby [script]'
        exit T.must(Lox::Config.exit_code[:usage])
      elsif args.size == 1
        @process.run_file T.must(args[0])
      else
        # @process.run_prompt # Run interactively
        @err.puts 'Interactive mode not yet implemented.'
        exit T.must(Lox::Config.exit_code[:usage])
      end
    end
  end
end
