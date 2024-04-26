# Lib's provide a way to group C functions and expose a library

require 'parser/ast/utils/scope'

module StoutLang
  module Ast
    class Lib < AstNode
      include Scope
      setup :name, :block
      attr_accessor :ir


      def prepare
        # Add the lib to the parent scope
        if parent_scope
          parent_scope.register_identifier(name, self)
        end

        block.prepare
      end

      def run
        block.run
      end

      def codegen(compile_jit, mod, func, bb)
        block.codegen(compile_jit, mod, func, bb, true)
      end
    end
  end
end
