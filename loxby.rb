# Lox interpreter in Ruby

# Entry point for script. Print usage if
# too many arguments, run script if script
# file provided, run interactively if run
# alone.
INTERPRETER = Lox.new
if ARGV.size > 1
  puts "Usage: loxby.rb [script]"
  exit 64
elsif ARGV.size == 1
  INTERPRETER.run_file ARGV[0]
else
  INTERPRETER.run_prompt
end

class Lox
  # Run from file
  def run_file(path)
    run File.read(path)
  end

  # Run interactively
  def run_prompt
    loop do
      print "> "
      line = gets
      break unless line # Trap eof (Ctrl+D unix, Ctrl+Z win)
      run line
    end
  end

  # Run a string
  def run(source)
    tokens = Scanner.new(source).scan

    # For now, just print tokens.
    tokens.each { puts _1 }
  end
end

class Lox::Scanner
  def initialize(source)
    @source = source
  end

  def scan
    # For now, just return a list of characters.
    @source.chars
  end
end