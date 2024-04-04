require 'parser/ast/utils/scope'

module StoutLang
  module Ast
    class Struct < AstNode
      include Scope
      setup :name, :block

      def prepare
        block.prepare
      end
    end
  end
end
