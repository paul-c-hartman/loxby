# Lox interpreter in Ruby
# frozen_string_literal: true
# typed: strict

require 'zeitwerk'
require 'sorbet-runtime'

# Configure Zeitwerk autoloader
loader = T.let(Zeitwerk::Loader.for_gem(warn_on_extra_files: false), Zeitwerk::GemLoader)
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
  extend T::Sig

  sig { returns(T::Boolean) }
  attr_reader :errored, :errored_in_runtime

  sig { returns(Lox::Interpreter) }
  attr_reader :interpreter

  sig { returns(IO) }
  attr_reader :out, :err

  sig { params(out: IO, err: IO).void }
  def initialize(out = $stdout, err = $stderr)
    # Whether an error occurred while parsing
    @errored = T.let(false, T::Boolean)
    # Whether an error occurred while interpreting
    @errored_in_runtime = T.let(false, T::Boolean)
    # `Interpreter` instance. Static so interactive sessions reuse it
    @interpreter = T.let(Lox::Interpreter.new(self), Lox::Interpreter)
    @out = T.let(out, IO)
    @err = T.let(err, IO)
  end

  # Parse and run a file
  sig { params(path: String).void }
  def run_file(path)
    if File.exist? path
      catch(:lox_exit) do
        run File.read(path)
      end
    else
      report(0, '', "No such file: '#{path}'")
    end
    exit T.must(Lox::Config.exit_code[:syntax_error]) if @errored # Don't execute malformed code
    exit T.must(Lox::Config.exit_code[:runtime_error]) if @errored_in_runtime
  end

  # Interactive prompt
  sig { void }
  def run_prompt
    @out.puts "Loxby #{Lox::VERSION}"
    loop do
      @out.print '> '
      input = gets.chomp
      break if input.empty?

      run(input)
      @errored = false # Reset error flag
    end
  end

  # Parse and run a string
  sig { params(source: String).void }
  def run(source)
    scanner = Lox::Scanner.new(source, self)
    tokens = scanner.process
    puts tokens # For now, just print the tokens
  end

  sig { params(line: Integer, message: String).void }
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

  sig { params(line: Integer, where: String, message: String).void }
  def report(line, where, message)
    @err.puts "[line #{line}] Error#{where}: #{message}"
    @errored = true
  end
end
