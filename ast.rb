require_relative 'loxby'
require_relative 'ast_visitors'

class String
  def to_camel_case
    to_s.split(/[_\-]/).map(&:capitalize).join('')
  end
end

class Symbol
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
      types.each do |class_name, fields|
        define_type(base_class, class_name, fields)
      end

      define_class base_name, base_class
    end

    def define_type(base_class, class_name, fields)
      subtype = Class.new(base_class)
      parameters = fields.map { _1[1].to_s }
      subtype.class_eval <<~RUBY
        include Visitable
        attr_reader #{parameters.map { ":" + _1 }.join(', ')}
        def initialize(#{parameters.map { _1 + ":" }.join(', ')})
          #{parameters.map { "@" + _1 }.join(', ')} = #{parameters.join ', '}
        end

        def accept(visitor)
          visitor.visit_#{class_name}(self)
        end
      RUBY

      define_class(class_name.to_camel_case, subtype, base_class:)
    end

    def define_class(class_name, klass, base_class: Lox::AST)
      base_class.const_set class_name, klass
    end
  end
end

Lox::AST.define_ast(
  "Expression",
  {
    :binary => [[:expr, :left], [:token, :operator], [:expr, :right]],
    :grouping => [[:expr, :expression]],
    :literal => [[:object, :value]],
    :unary => [[:token, :operator], [:expr, :right]]
  }
)