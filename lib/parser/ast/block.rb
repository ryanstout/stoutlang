module StoutLang
  module Ast
    class Block < AstNode
      setup :expressions

      def prepare
        expressions.each(&:prepare)
      end

      def run
        expressions.map(&:run).last
      end
    end
  end
end
