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

      def effects
        expressions.map(&:effects).flatten.uniq
      end

      def add_expression(expression)
        expressions << expression
      end

      def codegen(mod, bb)
        expressions.map do |exp|
          exp.codegen(mod, bb)
        end.last
      end
    end
  end
end
