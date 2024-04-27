module StoutLang
  module Ast
    class IntegerLiteral < AstNode
      setup :value

      def type
        Type.new("Int")
      end

      def run
        value
      end

      def codegen(compile_jit, mod, func, bb)
        LLVM::Int(value)
      end
    end
  end
end
