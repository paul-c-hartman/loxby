# frozen_string_literal: true

require_relative '../visitors/base'

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
  # Interface:
  #   Lox::AST.define_ast(
  #     "ASTBaseClass",
  #     {
  #       :ast_type => [[:field_one_type, :field_one_name], [:field_two_type, :field_two_name]],
  #       :other_ast_type => [[:field_type, :field_name]]
  #     }
  #   )
  #
  # This defines Lox::AST::ASTBaseClass, which ::AstType and ::OtherAstType descend from
  # and are scoped under. It also defines the Visitor pattern: AstType defines #accept(visitor),
  # which calls `visitor.visit_ast_type(self)`
  module AST
    module_function

    def define_ast(base_name, types)
      base_class = Class.new
      base_class.include Visitable
      # Define boilerplate visitor methods
      Visitor.define_types(base_name, types.keys)
      # Dynamically create subclasses for each AST type
      types.each do |class_name, fields|
        define_type(base_class, base_name, class_name, fields)
      end

      define_class base_name.to_camel_case, base_class
    end

    def define_type(base_class, base_class_name, subtype_name, fields) # rubocop:disable Metrics/MethodLength
      subtype = Class.new(base_class)
      parameters = fields.map { _1[1].to_s }

      subtype.class_eval <<~RUBY, __FILE__, __LINE__ + 1
        include Visitable # Visitor pattern
        attr_reader #{parameters.map { ":#{_1}" }.join(', ')}
        def initialize(#{parameters.map { "#{_1}:" }.join(', ')})
          #{parameters.map { "@#{_1}" }.join(', ')} = #{parameters.join ', '}
        end

        # Dynamically generated for visitor pattern.
        # Expects visitor to define #visit_#{subtype_name}
        def accept(visitor)
          visitor.visit_#{subtype_name}_#{base_class_name}(self)
        end
      RUBY

      define_class(subtype_name.to_camel_case, subtype, base_class:)
    end

    def define_class(class_name, klass, base_class: Lox::AST)
      base_class.const_set class_name, klass
    end
  end
end

Lox::AST.define_ast(
  :expression,
  {
    assign: [%i[token name], %i[expr value]],
    binary: [%i[expr left], %i[token operator], %i[expr right]],
    ternary: [%i[expr left], %i[token left_operator], %i[expr center], %i[token right_operator], %i[expr right]],
    grouping: [%i[expr expression]],
    literal: [%i[object value]],
    unary: [%i[token operator], %i[expr right]],
    variable: [%i[token name]]
  }
)

Lox::AST.define_ast(
  :statement,
  {
    block: [%i[stmt_list statements]],
    expression: [%i[expr expression]],
    print: [%i[expr expression]],
    var: [%i[token name], %i[expr initializer]]
  }
)
