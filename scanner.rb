require_relative 'loxby'
require_relative 'token_type'

class Lox::Scanner
  attr_accessor :line
  def initialize(source, interpreter)
    @source = source
    @tokens = []
    @interpreter = interpreter
    # Variables for scanning
    @start = 0
    @current = 0
    @line = 1
  end

  def scan_tokens
    until end_of_source?
      # Beginnning of next lexeme
      @start = @current
      scan_token
    end

    # Implicitly return @tokens
    @tokens << Lox::Token.new(:eof, "", nil, @line)
  end

  def end_of_source? = @current >= @source.size

  def scan_token
    character = advance_character

    case character
    # Single-character tokens
    when '('
      add_token :left_paren
    when ')'
      add_token :right_paren
    when '{'
      add_token :left_brace
    when '}'
      add_token :right_brace
    when ','
      add_token :comma
    when '.'
      add_token :dot
    when '-'
      add_token :minus
    when '+'
      add_token :plus
    when ';'
      add_token :semicolon
    when '*'
      add_token :star
    # 1-2 character tokens
    when '!'
      add_token match('=') ? :bang_equal : :bang
    when '='
      add_token match('=') ? :equal_equal : :equal
    when '<'
      add_token match('=') ? :less_equal : :less
    when '>'
      add_token match('=') ? :greater_equal : :greater
    when '/'
      # '/' is division, and '//' is comment. Needs special care.
      if match('/') # comment line
        advance_character until peek == "\n" || end_of_source?
      else
        add_token :slash
      end
    # Whitespace
    when "\n"
      @line += 1
    when /\s/
      # Ignore
    else
      # Unknown character
      @interpreter.error(@line, "Unexpected character.")
    end
  end

  def advance_character
    character = @source[@current]
    @current += 1
    character
  end

  def add_token(type, literal = nil)
    text = @source[@start...@current]
    @tokens << Lox::Token.new(type, text, literal, @line)
  end

  def match(expected)
    return false unless @source[@current] == expected || end_of_source?

    @current += 1
    true
  end

  # 1-character lookahead
  def peek
    end_of_source? ? "\0" : @source[@current]
  end
end