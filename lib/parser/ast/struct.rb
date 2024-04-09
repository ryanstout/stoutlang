require 'parser/ast/utils/scope'

module StoutLang
  module Ast
    class Struct < AstNode
      include Scope
      setup :name, :block

      def add_expression(expression)
        block.add_expression(expression)
      end

      def prepare
        block.prepare
      end

      def run
        block.run
      end

      def codegen(mod, func, bb)
        block.codegen(mod, func, bb)
      end
    end
  end
end
