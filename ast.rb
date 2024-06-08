require_relative 'loxby'

class Lox
  module AST
    module_function

    def define_ast(base_name, types)
      base_class = Class.new
      types.each do |class_name, fields|
        define_type(base_class, class_name.to_s.capitalize, fields)
      end

      define_class base_name, base_class
    end

    def define_type(base_class, class_name, fields)
      subtype = Class.new(base_class)
      parameters = fields.map { _1[1].to_s }
      subtype.class_eval <<~RUBY
        attr_reader #{parameters.map { ":" + _1 }.join(', ')}
        def initialize(#{parameters.map { _1 + ":" }.join(', ')})
          #{parameters.map { "@" + _1 }.join(', ')} = #{parameters.join ', '}
        end
      RUBY

      define_class class_name, subtype
    end

    def define_class(class_name, klass)
      const_set class_name, klass
    end
  end
end