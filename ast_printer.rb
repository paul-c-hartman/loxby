require_relative 'ast_visitors'

class ASTPrinter < Visitor
  def print(expression)
    expression.accept self
  end

  def parenthesize(*args)
    str = "(#{args[0]}"
    args[1..].each do |expr|
      str << " #{expr.accept self}"
    end
    str << ")"
  end

  def visit_binary_expression(expr)
    parenthesize expr.operator.lexeme, expr.left, expr.right
  end

  def visit_grouping_expression(expr)
    parenthesize "group", expr.expression
  end

  def visit_literal_expression(expr)
    expr.value.to_s
  end

  def visit_unary_expression(expr)
    parenthesize expr.operator.lexeme, expr.right
  end
end