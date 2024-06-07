# Lox interpreter in Ruby

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
    tokens = Scanner.new(source, self).scan

    # For now, just print tokens.
    tokens.each { puts _1 }
  end

  def error(line, message)
    report(line, "", message)
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