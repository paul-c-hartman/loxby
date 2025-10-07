# frozen_string_literal: true
# typed: strict

class LoxConfig_ < T::Struct # rubocop:disable Style/Documentation,Naming/ClassAndModuleCamelCase
  const :exit_code, T::Hash[Symbol, Integer]
end

class Lox
  # Configuration for Loxby.
  Config = T.let(
    LoxConfig_.new(
      exit_code: {
        interrupt: 130,
        usage: 64,
        syntax_error: 65,
        runtime_error: 70
      }
    ),
    LoxConfig_
  )
end
