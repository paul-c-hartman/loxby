# frozen_string_literal: true
# typed: strict

class Lox
  # `Lox::Scanner` converts a string to
  # a series of tokens using a giant
  # `case` statement.
  class Scanner
    extend T::Sig

    @@keywords = T.let( # rubocop:disable Style/ClassVars
      {
        'and' => :and,
        'class' => :class,
        'else' => :else,
        'false' => :false,
        'for' => :for,
        'fun' => :fun,
        'if' => :if,
        'nil' => :nil,
        'or' => :or,
        'print' => :print,
        'return' => :return,
        'super' => :super,
        'this' => :this,
        'true' => :true,
        'var' => :var,
        'while' => :while
      }, T::Hash[String, Symbol]
    )

    sig { params(source: String, process: Lox).void }
    def initialize(source, process)
      @source = source
      @tokens = T.let([], T::Array[Lox::Token])
      @start = T.let(0, Integer)
      @current = T.let(0, Integer)
      @line = T.let(1, Integer)
      @process = process
    end

    sig { returns(T::Array[Lox::Token]) }
    def scan_tokens
      until end_of_input?
        @start = @current
        scan_token
      end

      @tokens << Lox::Token.new(:EOF, '', nil, @line)
    end

    alias process scan_tokens

    private

    sig { void }
    def scan_token # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/AbcSize,Metrics/PerceivedComplexity
      char = advance
      case char
      when '('
        add_token(:left_paren)
      when ')'
        add_token(:right_paren)
      when '{'
        add_token(:left_brace)
      when '}'
        add_token(:right_brace)
      when ','
        add_token(:comma)
      when '.'
        add_token(:dot)
      when '-'
        add_token(:minus)
      when '+'
        add_token(:plus)
      when ';'
        add_token(:semicolon)
      when '*'
        add_token(:star)
      when '?'
        add_token(:question)
      when ':'
        add_token(:colon)
      when '!'
        add_token(match('=') ? :bang_equal : :bang)
      when '='
        add_token(match('=') ? :equal_equal : :equal)
      when '<'
        add_token(match('=') ? :less_equal : :less)
      when '>'
        add_token(match('=') ? :greater_equal : :greater)
      when '/'
        if match('/')
          advance until end_of_input? || peek == "\n"
        elsif match('*')
          # Multi-line comment
          until end_of_input? || (peek == '*' && peek_next == '/')
            @line += 1 if peek == "\n"
            advance
          end
          advance unless end_of_input? # Consume the '*'
          advance unless end_of_input? # Consume the '/'
        else
          add_token(:slash)
        end
      when ' ', "\r", "\t"
        # Ignore whitespace
      when "\n"
        @line += 1
      when '"'
        string
      else
        if char.match?(/\d/)
          number
        elsif char.match?(/[a-zA-Z_]/)
          identifier
        else
          @process.error(@line, "Unexpected character: '#{char}'")
        end
      end
    end

    sig { void }
    def identifier
      advance while peek.match?(/[a-zA-Z0-9_]/)
      text = T.must(@source[@start...@current])
      type = @@keywords[text] || :identifier
      add_token(type)
    end

    sig { void }
    def string
      until peek == '"' || end_of_input?
        @line += 1 if peek == "\n"
        advance
      end

      @process.error(@line, 'Unterminated string.') if end_of_input?
      advance # The closing "

      value = T.must(@source[(@start + 1)...(@current - 1)])
      add_token(:string, value)
    end

    sig { params(expected: String).returns(T::Boolean) }
    def match(expected)
      return false if end_of_input?
      return false unless @source[@current] == expected

      @current += 1
      true
    end

    sig { returns(String) }
    def peek
      return '' if end_of_input?

      T.must(@source[@current])
    end

    sig { returns(String) }
    def peek_next
      return '' if @current + 1 >= @source.length

      T.must(@source[@current + 1])
    end

    sig { void }
    def number
      advance while peek.match?(/\d/)
      if peek == '.' && peek_next.match?(/\d/)
        advance # Consume the "."
        advance while peek.match?(/\d/)
      end

      value = T.must(@source[@start...@current])
      # T.unsafe shenanigans since Sorbet doesn't mark Kernel#Integer
      # as returning T.nilable(Integer) with `exception: false`. This
      # should still propagate types correctly for static checks.
      add_token(:number, T.let(T.unsafe(Integer(value, exception: false)) || Float(value), T.any(Integer, Float)))
    end

    sig { returns(T::Boolean) }
    def end_of_input?
      @current >= @source.length
    end

    sig { returns(String) }
    def advance
      char = T.must(@source[@current])
      @current += 1
      char
    end

    sig { params(type: Symbol, literal: T.untyped).void }
    def add_token(type, literal = nil)
      text = T.must(@source[@start...@current])
      @tokens << Lox::Token.new(type, text, literal, @line)
    end
  end
end
