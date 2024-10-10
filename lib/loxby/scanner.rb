# frozen_string_literal: true

require_relative 'helpers/token_type'

class Lox
  # `Lox::Scanner` converts a string to
  # a series of tokens using a giant
  # `case` statement.
  class Scanner
    # Custom character classes for certain tokens.
    EXPRESSIONS = {
      whitespace: /\s/,
      number_literal: /\d/,
      identifier: /[a-zA-Z_]/
    }.freeze
    # Map of keywords to token types.
    # Right now, all keywords have
    # their own token type.
    KEYWORDS = %w[and class else false for fun if nil or print return super this true var while break]
               .map { [_1, _1.to_sym] }
               .to_h

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

    # Process text source into
    # a list of tokens.
    def scan_tokens
      until end_of_source?
        # Beginnning of next lexeme
        @start = @current
        scan_token
      end

      # Implicitly return @tokens
      @tokens << Lox::Token.new(:eof, '', nil, @line)
    end

    # Consume enough characters for the next token.

    def scan_token # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
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
      when '?'
        add_token :question
      when ':'
        add_token :colon
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
        # '/' is division, '//' is comment, '/* ... */'
        # is block comment. Needs special care.
        if match('/') # comment line
          advance_character until peek == "\n" || end_of_source?
        elsif match('*') # block comment
          scan_block_comment
        else
          add_token :slash
        end
      # Whitespace
      when "\n"
        @line += 1
      when EXPRESSIONS[:whitespace]
      # Literals
      when '"'
        scan_string
      when EXPRESSIONS[:number_literal]
        scan_number
      # Keywords and identifiers
      when EXPRESSIONS[:identifier]
        scan_identifier
      else
        # Unknown character
        @interpreter.error(@line, 'Unexpected character.')
      end
    end

    def scan_block_comment # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
      advance_character until (peek == '*' && peek_next == '/') || (peek == '/' && peek_next == '*') || end_of_source?

      if end_of_source? || peek_next == "\0" # If 0 or 1 characters are left
        @interpreter.error(line, 'Unterminated block comment.')
        return
      elsif peek == '/' && peek_next == '*'
        # Nested block comment. Skip opening characters
        match '/'
        match '*'
        scan_block_comment # Skip nested comment
        advance_character until (peek == '*' && peek_next == '/') || (peek == '/' && peek_next == '*') || end_of_source?
      end

      # Skip closing characters
      match '*'
      match '/'
    end

    def scan_string # rubocop:disable Metrics/MethodLength
      until peek == '"' || end_of_source?
        @line += 1 if peek == "\n" # Multiline strings are valid
        advance_character
      end

      if end_of_source?
        @interpreter.error(line, 'Unterminated string.')
        return
      end

      # Skip closing "
      advance_character

      # Trim quotes around literal
      value = @source[(@start + 1)...(@current - 1)]
      add_token :string, value
    end

    def scan_number
      advance_character while peek =~ EXPRESSIONS[:number_literal]

      # Check for decimal
      if peek == '.' && peek_next =~ EXPRESSIONS[:number_literal]
        # Consume decimal point
        advance_character
        advance_character while peek =~ EXPRESSIONS[:number_literal]
      end

      add_token :number, @source[@start...@current].to_f
    end

    def scan_identifier
      advance_character while peek =~ Regexp.union(EXPRESSIONS[:identifier], /\d/)
      text = @source[@start...@current]
      add_token(KEYWORDS[text] || :identifier)
    end

    # Move the pointer ahead one character and return it.
    def advance_character
      character = @source[@current]
      @current += 1
      character
    end

    # Emit a token.
    def add_token(type, literal = nil)
      text = @source[@start...@current]
      @tokens << Lox::Token.new(type, text, literal, @line)
    end

    # Move the pointer ahead if character matches expected character; error otherwise.
    def match(expected)
      return false unless @source[@current] == expected || end_of_source?

      @current += 1
      true
    end

    def end_of_source? = @current >= @source.size

    # 1-character lookahead
    def peek
      end_of_source? ? "\0" : @source[@current]
    end

    # 2-character lookahead
    def peek_next
      (@current + 1) > @source.size ? "\0" : @source[@current + 1]
    end
  end
end
