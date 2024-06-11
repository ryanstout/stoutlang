module StoutLang
  module Ast
    class Block < AstNode
      setup :expressions, :args

      def prepare
        args.each(&:prepare) if args
        expressions.each(&:prepare)

        self.expressions = expressions.map(&:resolve)
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
        self.expressions = expressions.map(&:resolve)
        self
      end

      # The return type of the block
      def return_type
        expressions.last.return_type
      end

      def build_block(compile_jit, mod, func, bb)
        # Add each expression on to the block, return the last one. The function calling this
        # codegen should add the return instruction.
        last_expr = expressions.map do |exp|
          exp.codegen(compile_jit, mod, func, bb)
        end.last

        return last_expr
      end

      # When the block is in a def, we build it into the def's function
      # When it's not in a def, we create a closure. (since it will be used as an argument)
      def codegen(compile_jit, mod, func, bb, in_def=false)
        if true || in_def
          if bb
            return build_block(compile_jit, mod, func, bb)
          else
            if func
              # There are some expressions besides functions, add to a basic block in the current function
              func.basic_blocks.append.build do |bb|
                return build_block(compile_jit, mod, func, bb)
              end
            else
              # No parent function, don't create a basic block, just build.
              # We're assuming all blocks are functions (we're in a lib)
              return build_block(compile_jit, mod, func, bb)
            end
          end
        else
          return codegen_block_argument(compile_jit, mod, func, bb)
        end
      end

      def codegen_block_argument(compile_jit, mod, func, bb)
        # Create a closure
        # func = mod.functions.add("block", [], self.return_type) do |function|
        #   # function.basic_blocks.append('entry').build do |b|
        #   #   build_block(compile_jit, mod, function, b)
        #   # end
        # end

        return build_block(compile_jit, mod, function, bb)
      end
    end
  end
end
