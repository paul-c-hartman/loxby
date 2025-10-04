# frozen_string_literal: true

require 'dry-configurable'

class Lox
  # Configuration for Loxby.
  # Uses dry-configurable gem.
  module Config
    extend Dry::Configurable

    setting :scanner do
      setting :expressions do
        setting :whitespace, default: /\s/
        setting :number_literal, default: /\d/
        setting :identifier, default: /[a-zA-Z_]/
      end

      setting :keywords,
              default: %w[and class else false for fun if nil or print return super this true var while break]
    end

    setting :token_types do
      setting :tokens, default: [
        # Single-character tokens.
        :left_paren, :right_paren, :left_brace, :right_brace,
        :comma, :dot, :minus, :plus, :semicolon, :slash, :star,
        :question, :colon, :percent,

        # 1-2 character tokens.
        :bang, :bang_equal,
        :equal, :equal_equal,
        :greater, :greater_equal,
        :less, :less_equal,

        # Literals.
        :identifier, :string, :number,

        # Keywords.
        :and, :class, :else, :false, :fun, :for, :if, :nil, :or,
        :print, :return, :super, :this, :true, :var, :while, :break,

        :eof
      ].freeze

      setting :single_tokens,
              default: '(){},.-+;/*?:%',
              constructor: -> { _1.split('').zip(Lox::Config.config.token_types.tokens).to_h }
    end

    setting :native_functions, default: [], reader: true

    setting :ast do
      setting :expression,
              default: {
                assign: [%i[token name], %i[expr value]],
                binary: [%i[expr left], %i[token operator], %i[expr right]],
                ternary: [%i[expr left], %i[token left_operator], %i[expr center], %i[token right_operator],
                          %i[expr right]],
                call: [%i[expr callee], %i[token paren], %i[expr_list arguments]],
                grouping: [%i[expr expression]],
                literal: [%i[object value]],
                logical: [%i[expr left], %i[token operator], %i[expr right]],
                unary: [%i[token operator], %i[expr right]],
                variable: [%i[token name]]
              }
      setting :statement,
              default: {
                block: [%i[stmt_list statements]],
                expression: [%i[expr expression]],
                function: [%i[token name], %i[token_list params], %i[stmt_list body]],
                if: [%i[expr condition], %i[stmt then_branch], %i[stmt else_branch]],
                print: [%i[expr expression]],
                return: [%i[token keyword], %i[expr value]],
                var: [%i[token name], %i[expr initializer]],
                while: [%i[expr condition], %i[stmt body]],
                break: []
              }
    end

    setting :exit_code do
      setting :interrupt, default: 130
      setting :usage, default: 64
      setting :syntax_error, default: 65
      setting :runtime_error, default: 70
    end
  end
end
