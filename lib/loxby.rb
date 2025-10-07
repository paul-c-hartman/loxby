# Lox interpreter in Ruby
# frozen_string_literal: true
# typed: true

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
    exit Lox::CONFIG[:exit_code][:syntax_error] if @errored # Don't execute malformed code
    exit Lox::CONFIG[:exit_code][:runtime_error] if @errored_in_runtime
  end

  # Parse and run a string
  def run(source)
    steps = [
      Lox::Scanner,
      Lox::Parser,
      Lox::Resolver
    ]
    code = source
    steps.each do |step|
      instance = step.new(code, self)
      code = instance.process
      break if @errored
    end
    @interpreter.interpret(code) unless @errored
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
