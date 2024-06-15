require "parser/ast/ast_node"

module StoutLang
  module Ast
    class LocalVar < AstNode
      setup :name, :type

      attr_accessor :ir

      def codegen(compile_jit, mod, func, bb)
        unless ir
          # This would mean we reached codegen before the assignment ran, it shouldn't ever
          # happen.
          raise "Local variable not yet evaluated"
        end

        self.ir
      end
    end
  end
end
