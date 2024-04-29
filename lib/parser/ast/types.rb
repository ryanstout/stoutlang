module StoutLang
  module Ast

    # A Type is like an Identifier for a base level type
    class Type < AstNode
      setup :name
      attr_accessor :type

      def prepare

      end

      def run
        self
      end

      def mangled_name
        name
      end

      def codegen(compile_jit, mod, func, bb)
        # Lookup the type in the scope
        self.type = lookup_identifier(name)

        unless self.type
          raise "Type not found: #{name}"
        end

        if self.type.is_a?(Class) && self.type < StoutLang::BaseType
          return self.type.new.codegen(compile_jit, mod, func, bb)
        end

        if self.type.is_a?(StoutLang::Ast::Struct)
          return self.type.codegen(compile_jit, mod, func, bb)
        end

        raise "Not a Stoutlang type: #{name} -- #{self.type.inspect}"
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

      def mangled_name
        type_val.mangled_name
      end

      def codegen(compile_jit, mod, func, bb)
        raise "Type Val is nil" if type_val.nil?
        type_val.codegen(compile_jit, mod, func, bb)
      end
    end
  end
end
