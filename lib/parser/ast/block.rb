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

      def build_block(mod, func, bb)
        # Add each expression on to the block, return the last one. The function calling this
        # codegen should add the return instruction.
        last_expr = expressions.map do |exp|
          exp.codegen(mod, func, bb)
        end.last

        return bb, last_expr
    end

      def codegen(mod, func, bb)
        if bb
          return build_block(mod, func, bb)
        else
          func.basic_blocks.append.build do |bb|
            return build_block(mod, func, bb)
          end
        end
      end
    end
  end
end
