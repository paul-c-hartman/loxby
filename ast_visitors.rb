module Visitable
  def accept(visitor)
    raise NotImplementedError, "#{self.class} has not implemented #accept"
  end
end

class Visitor
  def visit_binary(_)
    raise NotImplementedError, "#{self.class} has not implemented #visit_binary"
  end
  
  def visit_grouping(_)
    raise NotImplementedError, "#{self.class} has not implemented #visit_grouping"
  end

  def visit_literal(_)
    raise NotImplementedError, "#{self.class} has not implemented #visit_literal"
  end

  def visit_unary(_)
    raise NotImplementedError, "#{self.class} has not implemented #visit_unary"
  end
end