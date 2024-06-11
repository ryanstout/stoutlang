module StoutLang
  module Ast
    class BlockType < AstNode
      setup :block_args, :block_return_type

      def codegen(compile_jit, mod, func, bb)
        raise "Not implemented"
      end
    end
  end
end
