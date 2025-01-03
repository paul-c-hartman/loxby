# frozen_string_literal: true

require_relative 'base'

# This visitor prints a given AST
# for easier viewing and debugging.
class ASTPrinter < Visitor
  def print(expression)
    expression.accept self
  end

  def parenthesize(*args)
    str = "(#{args[0]}"
    args[1..].each do |expr|
      str << " #{expr.accept self}"
    end
    str << ')'
  end

  def visit_binary_expression(expr)
    parenthesize expr.operator.lexeme, expr.left, expr.right
  end

  def visit_ternary_expression(expr)
    parenthesize expr.left_operator.lexeme + expr.right_operator.lexeme, expr.left, expr.center, expr.right
  end

  def visit_grouping_expression(expr)
    parenthesize 'group', expr.expression
  end

  def visit_literal_expression(expr)
    expr.value.nil? ? 'nil' : expr.value.to_s
  end

  def visit_unary_expression(expr)
    parenthesize expr.operator.lexeme, expr.right
  end

  def visit_assign_expression(expr)
    parenthesize 'assign', expr.name, expr.value
  end

  def visit_call_expression(expr)
    parenthesize 'call', expr.callee, expr.arguments
  end

  def visit_logical_expression(expr)
    visit_binary_expression(expr)
  end

  def visit_variable_expression(expr)
    parenthesize 'var', expr.name
  end
end
