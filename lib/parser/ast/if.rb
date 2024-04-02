module StoutLang
  module Ast
    class If < AstNode
      setup :condition, :if_block, :elifs_blocks, :else_block

      def prepare
        if_block.prepare
        elifs_blocks.each(&:prepare)
        else_block.prepare if else_block
      end
    end

    class ElifClause < AstNode
      setup :condition, :block

      def prepare
        block.prepare
      end
    end

    class ElseClause < AstNode
      setup :block

      def prepare
        block.prepare
      end
    end
  end
end
