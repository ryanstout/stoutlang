module StoutLang
  module Ast
    class Property < AstNode
      setup :name, :type_sig

      def prepare
        type_sig.prepare
      end

      def codegen(compile_jit, mod, func, bb)
        # This is handled at the struct level
      end
    end
  end
end
