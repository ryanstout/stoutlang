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

      def build_block(compile_jit, mod, func, bb)
        # Add each expression on to the block, return the last one. The function calling this
        # codegen should add the return instruction.
        last_expr = expressions.map do |exp|
          exp.codegen(compile_jit, mod, func, bb)
        end.last

        return last_expr
    end

      def codegen(compile_jit, mod, func, bb)
        if bb
          return build_block(compile_jit, mod, func, bb)
        else
          if func
            # There are some expressions besides functions, add to a basic block in the current function
            func.basic_blocks.append.build do |bb|
              return build_block(compile_jit, mod, func, bb)
            end
          else
            # No parent function, don't createa a basic block, just build.
            # We're assuming all blocks are functions (we're in a lib)
            return build_block(compile_jit, mod, func, bb)
          end
        end
      end
    end
  end
end
