# frozen_string_literal: true

require_relative 'base'

# This visitor converts single expression
# ASTs to Reverse Polish Notation.
class RPNConverter < Visitor
  def print(expr)
    expr.accept self
  end

  def visit_binary_expression(expr)
    "#{expr.left.accept self} #{expr.right.accept self} #{expr.operator.lexeme}"
  end

  def visit_grouping_expression(expr)
    expr.accept self
  end

  def visit_literal_expression(expr)
    expr.value.to_s
  end

  def visit_unary_expression(expr)
    "#{expr.right.accept self} #{expr.operator.lexeme}"
  end
end
