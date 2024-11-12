# frozen_string_literal: true

require_relative 'scanner'
require_relative 'parser'
require_relative 'resolver'
require_relative 'interpreter'
require_relative 'helpers/token_type'
require_relative 'config'

# Lox interpreter.
# Each interpreter keeps track of its own
# environment, including variable and
# function scope.
class Lox
  attr_reader :errored, :interpreter

  def initialize
    # Whether an error occurred while parsing.
    @errored = false
    # Whether an error occurred while interpreting
    @errored_in_runtime = false
    # `Lox::Interpreter` instance. Static so interactive sessions reuse it
    @interpreter = Interpreter.new(self)
  end

  # Parse and run a file
  def run_file(path)
    if File.exist? path
      catch(:lox_exit) do
        run File.read(path)
      end
    else
      report(0, '', "No such file: '#{path}'")
    end
    exit Lox.config.exit_code.syntax_error if @errored # Don't execute malformed code
    exit Lox.config.exit_code.runtime_error if @errored_in_runtime
  end

  # Run interactively, REPL-style
  def run_prompt
    catch(:lox_exit) do
      loop do
        print '> '
        line = gets
        break unless line # Trap eof (Ctrl+D unix, Ctrl+Z win)

        result = run(line)
        puts "=> #{@interpreter.lox_obj_to_str result}" unless @errored

        # When run interactively, resets after every prompt so as to not kill the repl
        @errored = false
      end
    end
  end

  # Parse and run a string
  def run(source)
    tokens = Scanner.new(source, self).scan_tokens
    parser = Parser.new(tokens, self)
    statements = parser.parse
    return if @errored

    resolver = Resolver.new(@interpreter)
    # No need to store output as this injects data
    # directly into the interpreter
    resolver.resolve statements
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
