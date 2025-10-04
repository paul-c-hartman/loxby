# frozen_string_literal: true

class String # rubocop:disable Style/Documentation
  def to_camel_case
    to_s.split(/[-_]/).map(&:capitalize).join('')
  end
end

class Symbol # rubocop:disable Style/Documentation
  def to_camel_case
    to_s.to_camel_case.to_sym
  end
end

class Lox
  module Helpers
    # Interface:
    # ```ruby
    #   Lox::Helpers::AST.define_ast(
    #     "ASTBaseClass",
    #     {
    #       :ast_type => [
    #         [:field_one_type, :field_one_name],
    #         [:field_two_type, :field_two_name]
    #       ],
    #       :other_ast_type => [[:field_type, :field_name]]
    #     }
    #   )
    # ```
    #
    # This call to `#define_ast` generates `Lox::Helpers::AST::ASTBaseClass`, as well as `::AstType` and
    # `::OtherAstType` descending from and scoped under it. Generated classes follow the Visitor
    # pattern: `::AstType` generates with `#accept(visitor)` which calls `visitor.visit_ast_type(self)`.
    module AST
      module_function

      def define_ast(base_name, types)
        base_class = Class.new
        base_class.include Visitable
        # Define boilerplate visitor methods
        Lox::Visitors::BaseVisitor.define_types(base_name, types.keys)
        # Dynamically create subclasses for each AST type
        types.each do |class_name, fields|
          define_type(base_class, base_name, class_name, fields)
        end

        define_class base_name.to_camel_case, base_class
      end

      def define_type(base_class, base_class_name, subtype_name, fields) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
        subtype = Class.new(base_class)
        parameters = fields.map { _1[1].to_s }

        subtype.class_eval <<~RUBY, __FILE__, __LINE__ + 1
          include Lox::Visitable # Visitor pattern
          #{parameters.empty? ? '' : 'attr_reader '}#{parameters.map { ":#{_1}" }.join(', ')}
          def initialize(#{parameters.map { "#{_1}:" }.join(', ')})
            #{parameters.map { "@#{_1}" }.join(', ')}#{parameters.empty? ? '' : ' = '}#{parameters.join ', '}
          end

          # This function was dynamically generated for visitor pattern.
          # Expects visitors to define `#visit_#{subtype_name}_#{base_class_name}`.
          def accept(visitor)
            visitor.visit_#{subtype_name}_#{base_class_name}(self)
          end
        RUBY

        define_class(subtype_name.to_camel_case, subtype, base_class:)
      end

      def define_class(class_name, klass, base_class: Lox::Helpers::AST)
        base_class.const_set class_name, klass
      end
    end
  end
end

# Default AST specification for loxby.
Lox::Config.config.ast.values.each do |name, definition|
  Lox::Helpers::AST.define_ast(name, definition)
end
