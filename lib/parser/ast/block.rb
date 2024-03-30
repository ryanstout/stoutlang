module StoutLang
  module Ast
    class Block < AstNode
      setup :expressions

      def run
        expressions.map(&:run).last
      end
    end
  end
end
