# Lib's provide a way to group C functions and expose a library

require 'parser/ast/utils/scope'

module StoutLang
  module Ast
    class Lib < AstNode
      include Scope
      setup :name, :body
      attr_accessor :ir

      def prepare
        # Add the lib to the parent scope
        if parent_scope
          parent_scope.register_identifier(name, self)
        end

        body.prepare
      end

      def run
        body.run
      end

      def codegen(compile_jit, mod, func, bb)
        body.codegen(compile_jit, mod, func, bb)
      end
    end
  end
end
