# Lox interpreter in Ruby
require_relative 'scanner'
require_relative 'token_type'
require_relative 'parser'
require_relative 'visitors/ast_printer'

class Lox
  attr_reader :errored
  def initialize
    @errored = false
  end

  # Run from file
  def run_file(path)
    run File.read(path)
    exit(65) if @errored # Don't execute malformed code
  end

  # Run interactively
  def run_prompt
    loop do
      print "> "
      line = gets
      break unless line # Trap eof (Ctrl+D unix, Ctrl+Z win)
      run line
      @errored = false # Reset so a mistake doesn't kill the repl
    end
  end

  # Run a string
  def run(source)
    tokens = Scanner.new(source, self).scan_tokens
    parser = Parser.new(tokens, self)
    expression = parser.parse

    # We have a parser now! :)
    return if @errored
    puts ASTPrinter.new.print(expression)
  end

  def error(line, message)
    if line.is_a? Lox::Token
      # Parse/runtime error
      where = line.type == :eof ? 'end' : "'#{line.lexeme}'"
      report(line.line, " at " + where, message)
    else
      # Scan error
      report(line, "", message)
    end
  end

  private def report(line, where, message)
    $stderr.puts "[line #{line}] Error#{where}: #{message}"
    @errored = true
  end
end

# Entry point for script. Print usage if
# too many arguments, run script if script
# file provided, run interactively if run
# alone. Don't run if loaded with `require`.
if __FILE__ == $PROGRAM_NAME
  INTERPRETER = Lox.new
  if ARGV.size > 1
    puts "Usage: loxby.rb [script]"
    exit 64
  elsif ARGV.size == 1
    INTERPRETER.run_file ARGV[0]
  else
    INTERPRETER.run_prompt
  end
end