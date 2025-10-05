# Lox interpreter in Ruby
# frozen_string_literal: true

require 'zeitwerk'

# Configure Zeitwerk autoloader
loader = Zeitwerk::Loader.for_gem(warn_on_extra_files: false)
loader.ignore("#{__dir__}/../test")
loader.inflector.inflect(
  'ast' => 'AST',
  'rpn_converter' => 'RPNConverter',
  'version' => 'VERSION',
  'loxby' => 'Lox'
)
loader.setup

# Lox interpreter.
# Each interpreter keeps track of its own
# environment, including variable and
# function scope.
class Lox
  attr_reader :errored, :interpreter, :out, :err

  def initialize(out = $stdout, err = $stderr)
    # Whether an error occurred while parsing
    @errored = false
    # Whether an error occurred while interpreting
    @errored_in_runtime = false
    # `Interpreter` instance. Static so interactive sessions reuse it
    @interpreter = Lox::Interpreter.new(self)
    @out = out
    @err = err
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
    exit Lox::Config.config.exit_code.syntax_error if @errored # Don't execute malformed code
    exit Lox::Config.config.exit_code.runtime_error if @errored_in_runtime
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
    return if @errored # To prevent running code when the resolver found an error

    @interpreter.interpret statements
  end

  def error(line, message)
    # if line.is_a? Lox::Helpers::Token
    #   # Parse/runtime error
    #   where = line.type == :eof ? 'end' : "'#{line.lexeme}'"
    #   report(line.line, " at #{where}", message)
    # else
    # Scan error
    report(line, '', message)
    # end
  end

  private

  def runtime_error(err)
    @err.puts err.message
    @err.puts "[line #{err.token.line}]"
    @errored_in_runtime = true
  end

  def report(line, where, message)
    @err.puts "[line #{line}] Error#{where}: #{message}"
    @errored = true
  end
end
