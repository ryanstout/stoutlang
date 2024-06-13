# An Exps ("Expressions" aka list of expressions) is an array of expressions. It serves as the body of Defs, Blocks,
# If's, etc...
module StoutLang
  module Ast
    class Exps < AstNode
      setup :expressions

      def prepare
        expressions.each(&:prepare)
        self.expressions = expressions.map(&:resolve)
      end

      def type
        # The type of an Exps is the type of the last expression.
        expressions.last.type
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

      def resolve
        self
      end

      # The return type of the block
      def return_type
        expressions.last.type
      end

      def codegen(compile_jit, mod, func, bb)
        # Add each expression on to the block, return the last one. The function calling this
        # codegen should add the return instruction.
        last_expr = expressions.map do |exp|
          exp.codegen(compile_jit, mod, func, bb)
        end.last

        return last_expr
      end


    end
  end
end
