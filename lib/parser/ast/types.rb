module StoutLang
  module Ast

    # A Type is like an Identifier for a base level type
    class Type < AstNode
      setup :name

      def type
        raise "Can not call .type on a Type"
      end

      def prepare
      end

      def run
        self
      end

      def resolve
        # This may not be a function, but will match either a zero arg function or something else
        # inspect_scope
        @resolved = lookup_identifier(name)

        unless @resolved
          raise "Identifier #{name} not found"
        end

        return @resolved
      end

      def mangled_name
        name
      end

      def codegen(compile_jit, mod, func, bb)
        resolved = self.resolve

        unless resolved
          raise "Type not found: #{name}"
        end

        if resolved.is_a?(StoutLang::BaseType)
          return resolved.codegen(compile_jit, mod, func, bb)
        end

        if resolved.is_a?(StoutLang::Ast::Struct)
          return resolved.codegen(compile_jit, mod, func, bb)
        end

        raise "Not a Stoutlang type: #{name} -- #{resolved.inspect}"
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

      def resolve
        type_val.resolve
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
