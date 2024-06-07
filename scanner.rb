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

    single_token_types = Lox::Token::SingleTokens
    single_token_types.delete :slash # Process this later
    type = single_token_types[character]

    if type
      add_token single_token_types[character]
    else
      # Unknown character
      @interpreter.error(@line, "Unexpected character.")
    end
  end

  def advance
    @current += 1
    @source[@current - 1]
  end

  def add_token(type, literal = nil)
    text = @source[@start..@current]
    @tokens << Lox::Token.new(type, text, literal, @line)
  end
end