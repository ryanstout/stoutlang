module StoutLang
  module Ast
    class If < AstNode
      setup :condition, :if_block, :elifs_blocks, :else_block

      def prepare
        condition.prepare
        if_block.prepare
        elifs_blocks.each(&:prepare)
        else_block.prepare if else_block
      end

      def codegen(compile_jit, mod, func, bb)
        # We need to create the basic blocks in the order we want them in the IR, so
        # this will require two passes.
        if_bb = func.basic_blocks.append('if_block')
        puts "IF BLOCK: #{self.inspect}"
        elifs_bbs = elifs_blocks.map do |elif_clause|
          puts "ELIF CLAUSE: #{elif_clause.inspect}"
          [
            # This block checks the elif condition. Jumps to elif_block below if true or
            # the next elif or else block if false
            func.basic_blocks.append('elif_cond_block'),
            # This runs if true
            func.basic_blocks.append('elif_block')
          ]
        end
        if else_block
          else_bb = func.basic_blocks.append('else_block')
        end
        merge_bb = func.basic_blocks.append('if_merge')


        if_cond_val = condition.codegen(compile_jit, mod, func, bb)
        if_false_bb = elifs_bbs.first ? elifs_bbs.first[0] : else_bb
        bb.cond(if_cond_val, if_bb, if_false_bb)

        if_bb.build do |b|
          puts "B: #{b.inspect}"
          if_block.codegen(compile_jit, mod, func, b)
          puts "MERGE BB: #{merge_bb.inspect}"
          b.br(merge_bb)
        end

        i = 0
        elifs_bbs.each do |cond_bb, elif_bb|
          false_jump_bb = elifs_bbs[i+1] ? elifs_bbs[i+1][0] : else_bb
          elif_cond = elifs_blocks[i].condition
          cond_bb.build do |b|
            elif_cond_val = elif_cond.codegen(compile_jit, mod, func, b)
            b.cond(elif_cond_val, elif_bb, false_jump_bb)
          end
          elif_block = elifs_blocks[i].block
          elif_bb.build do |b|
            # Condition for this elif was true
            elif_block.codegen(compile_jit, mod, func, b)
            b.br(merge_bb)
          end
          i += 1
        end

        if else_block
          else_bb.build do |b|
            else_block.codegen(compile_jit, mod, func, b)
            b.br(merge_bb)
          end
        else
          else_bb = merge_bb
        end

        merge_bb.build do |b|
          # Phi node
          # temp = b.phi(LLVM::Int1, 'if_merge_temp')
          # bb.ret(LLVM::Int(0))
        end

        bb.position_at_end(merge_bb)
        return merge_bb
      end
    end

    class ElifClause < AstNode
      setup :condition, :block

      def prepare
        condition.prepare
        block.prepare
      end

      def codegen(compile_jit, mod, func, bb)
        cond_val = condition.codegen(compile_jit, mod, func, bb)
        bb.cond(cond_val, bb.insert_block, nil)
        block.codegen(compile_jit, mod, func, bb)
      end
    end

    class ElseClause < AstNode
      setup :block

      def prepare
        block.prepare
      end

      def codegen(compile_jit, mod, func, bb)
        block.codegen(compile_jit, mod, func, bb)
      end
    end
  end
end
