module StoutLang
  module Ast

    # A Type is like an Identifier for a base level type
    class Type < AstNode
      setup :name
      attr_accessor :type

      def prepare
        self.type = lookup_identifier(name)
        # The type itself will have prepare called when it was constructed
      end

      def run
        self
      end

      def resolve
        # This may not be a function, but will match either a zero arg function or something else
        # inspect_scope
        identified = lookup_identifier(name)

        # binding.pry

        unless identified
          raise "Identifier #{name} not found"
        end

        return identified
      end

      def mangled_name
        name
      end

      def codegen(compile_jit, mod, func, bb)
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
