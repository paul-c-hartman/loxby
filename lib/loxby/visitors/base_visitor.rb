# frozen_string_literal: true

class Lox
  module Visitors
    # Base visitor class for visitor pattern.
    # See Visitable.
    class Lox::Visitors::BaseVisitor
      # Defines visit methods for each subtype of a base type.
      # For example, `define_types('expression', ['binary', 'literal'])`
      # defines `#visit_binary_expression` and `#visit_literal_expression`.
      #
      # Each defined method raises NotImplementedError.
      #
      # @param base_type [String] The base type name (e.g. 'expression')
      # @param subtypes [Array<String>] The subtype names (e.g. ['binary', 'literal'])
      def self.define_types(base_type, subtypes)
        subtypes.each do |subtype|
          method_name = "visit_#{subtype}_#{base_type}"
          define_method(method_name.to_sym) do |_|
            raise NotImplementedError, "#{self.class} has not implemented #{self.class}.#{method_name}"
          end
        end
      end

      def visit(_)
        raise NotImplementedError, "#{self.class} has not implemented #visit"
      end
    end
  end
end
