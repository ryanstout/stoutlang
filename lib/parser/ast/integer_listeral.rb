module StoutLang
  module Ast
    class IntegerLiteral < AstNode
      setup :value

      def run
        value
      end

      def codegen(mod, func, bb)
        LLVM::Int(value)
      end
    end
  end
end
