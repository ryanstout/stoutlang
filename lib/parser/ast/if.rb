module StoutLang
  module Ast
    class If < AstNode
      setup :condition, :if_body, :elifs_bodys, :else_body

      def prepare
        # resolve the conditions, the rest should be bodys, which resolve when they are prepared
        self.condition = condition.resolve

        condition.prepare
        if_body.prepare
        elifs_bodys.each(&:prepare)
        else_body.prepare if else_body
      end

      def codegen(compile_jit, mod, func, bb)
        # We need to create the basic bodys in the order we want them in the IR, so
        # this will require two passes.
        if_bb = func.basic_bodys.append('if_body')
        elifs_bbs = elifs_bodys.map do |elif_clause|
          [
            # This body checks the elif condition. Jumps to elif_body below if true or
            # the next elif or else body if false
            func.basic_bodys.append('elif_cond_body'),
            # This runs if true
            func.basic_bodys.append('elif_body')
          ]
        end
        if else_body
          else_bb = func.basic_bodys.append('else_body')
        end
        merge_bb = func.basic_bodys.append('if_merge')

        if_cond_val = condition.codegen(compile_jit, mod, func, bb)
        if_false_bb = elifs_bbs.first ? elifs_bbs.first[0] : else_bb
        bb.cond(if_cond_val, if_bb, if_false_bb)

        if_bb.build do |b|
          if_body.codegen(compile_jit, mod, func, b)
          b.br(merge_bb)
        end

        i = 0
        elifs_bbs.each do |cond_bb, elif_bb|
          false_jump_bb = elifs_bbs[i+1] ? elifs_bbs[i+1][0] : else_bb
          elif_cond = elifs_bodys[i].condition
          cond_bb.build do |b|
            elif_cond_val = elif_cond.codegen(compile_jit, mod, func, b)
            b.cond(elif_cond_val, elif_bb, false_jump_bb)
          end
          elif_body = elifs_bodys[i].body
          elif_bb.build do |b|
            # Condition for this elif was true
            elif_body.codegen(compile_jit, mod, func, b)
            b.br(merge_bb)
          end
          i += 1
        end

        if else_body
          else_bb.build do |b|
            else_body.codegen(compile_jit, mod, func, b)
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
      setup :condition, :body

      def prepare
        condition.prepare
        body.prepare
      end

      def codegen(compile_jit, mod, func, bb)
        cond_val = condition.codegen(compile_jit, mod, func, bb)
        bb.cond(cond_val, bb.insert_block, nil)
        body.codegen(compile_jit, mod, func, bb)
      end
    end

    class ElseClause < AstNode
      setup :body

      def prepare
        body.prepare
      end

      def codegen(compile_jit, mod, func, bb)
        body.codegen(compile_jit, mod, func, bb)
      end
    end
  end
end
