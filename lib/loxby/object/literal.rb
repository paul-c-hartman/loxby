# frozen_string_literal: true
# typed: strict

class Lox
  module Object
    # `Lox::Object::Literal` represents literal values in Lox,
    # such as numbers, strings, booleans, and nil.
    module Literal
      LoxLiteralTypes = T.type_alias { T.nilable(T.any(String, Integer, Float, T::Boolean)) }
    end
  end
end
