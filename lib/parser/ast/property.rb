module StoutLang
  module Ast
    class Property < AstNode
      setup :name, :type_sig

      def type
        type_sig.type_val
      end

      def prepare
        type_sig.prepare

        # Register this property with the struct
        parent_scope.register_in_scope("@#{name.name}", self)
      end

      def codegen(compile_jit, mod, func, bb)
        # This is handled at the struct level
      end
    end
  end
end
