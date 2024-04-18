module StoutLang
  module Ast
    class Type < AstNode
      setup :name
      attr_accessor :type

      def run
        self
      end

      def codegen(compile_jit, mod, func, bb)
        # Lookup the type in the scope
        self.type = lookup_identifier(name)

        unless self.type
          raise "Type not found: #{name}"
        end

        unless self.type < StoutLang::BaseType
          raise "Not a Stoutlang type: #{name} -- #{self.type.inspect}"
        end

        return self.type.new.codegen(compile_jit, mod, func, bb)
      end
    end

    class TypeVariable < AstNode
      setup :name

      def run
        self
      end
    end

    class TypeSig < AstNode
      setup :type_val

      def prepare
        type_val.prepare
      end

      def run
        self
      end

      def codegen(compile_jit, mod, func, bb)
        raise "Type Val is nil" if type_val.nil?
        type_val.codegen(compile_jit, mod, func, bb)
      end
    end
  end
end
