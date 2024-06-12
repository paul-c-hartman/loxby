# frozen_string_literal: true

require_relative 'scanner'
require_relative 'parser'
require_relative 'interpreter'
require_relative 'helpers/token_type'

# Lox interpreter.
# Each interpreter keeps track of its own
# environment, including variable and
# function scope.
class Lox
  attr_reader :errored, :interpreter

  def initialize
    @errored = false
    @errored_in_runtime = false
    @interpreter = Interpreter.new(self) # Make static so REPL sessions reuse it
  end

  # Run from file
  def run_file(path)
    run File.read(path)
    exit(65) if @errored # Don't execute malformed code
    exit(70) if @errored_in_runtime
  end

  # Run interactively
  def run_prompt
    loop do
      print '> '
      line = gets
      break unless line # Trap eof (Ctrl+D unix, Ctrl+Z win)

      result = run(line)
      puts "=> #{@interpreter.lox_obj_to_str result}" unless @errored
      @errored = false # Reset so a mistake doesn't kill the repl
    end
  end

  # Run a string
  def run(source)
    tokens = Scanner.new(source, self).scan_tokens
    parser = Parser.new(tokens, self)
    statements = parser.parse
    return if @errored

    @interpreter.interpret statements
  end

  def error(line, message)
    if line.is_a? Lox::Token
      # Parse/runtime error
      where = line.type == :eof ? 'end' : "'#{line.lexeme}'"
      report(line.line, " at #{where}", message)
    else
      # Scan error
      report(line, '', message)
    end
  end

  # rubocop:disable Style/StderrPuts

  def runtime_error(err)
    $stderr.puts err.message
    $stderr.puts "[line #{err.token.line}]"
    @errored_in_runtime = true
  end

  private

  def report(line, where, message)
    $stderr.puts "[line #{line}] Error#{where}: #{message}"
    @errored = true
  end
end
# rubocop:enable Style/StderrPuts
