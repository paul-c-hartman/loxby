# frozen_string_literal: true

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
        @out.puts
        exit Lox::Config.config.exit_code.interrupt
      end

      @interpreter = Lox.new(out, err)
      @out = out
      @err = err
    end

    def run(args)
      if args.size > 1
        @out.puts 'Usage: loxby [script]'
        exit Lox::Config.config.exit_code.usage
      elsif args.size == 1
        @interpreter.run_file args[0]
      else
        @interpreter.run_prompt # Run interactively
      end
    end

    def run_debug(args)
      if args.size != 2
        @out.puts "Usage: loxby-debug [tool] [script]\n\tTools:\n\t - ast_printer"
        return
      end

      tool = { ast_printer: Lox::Visitors::ASTPrinter }[args[0].to_sym]

      if File.exist? args[1]
        @interpreter.run_from_ast(File.read(args[1]), tool.new(@out, @err))
      else
        @interpreter.report(0, '', "No such file: '#{path}'")
      end
    end
  end
end
