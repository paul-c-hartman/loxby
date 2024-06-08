module Visitable
  def accept(visitor)
    raise NotImplementedError, "#{self.class} has not implemented #accept"
  end
end

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