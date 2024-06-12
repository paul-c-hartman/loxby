# frozen_string_literal: true

# Visitable adds #accept, the only
# method required to implement the
# visitor pattern on a class.
# To use the visitor pattern,
# `include Visitable` to your class
# and subclass `Visitor` to implement
# visitors.
module Visitable
  def accept(visitor)
    raise NotImplementedError, "#{self.class} has not implemented #accept"
  end
end

# Base visitor class for visitor pattern.
# See Visitable.
class Visitor
  def self.define_types(base_type, subtypes)
    subtypes.each do |subtype|
      method_name = "visit_#{subtype}_#{base_type}"
      define_method(method_name.to_sym) do |_|
        raise NotImplementedError, "#{self.class} has not implemented ##{method_name}"
      end
    end
  end
end
