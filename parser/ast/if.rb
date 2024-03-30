module StoutLang
  module Ast
    class If < AstNode
      setup :condition, :if_block, :elifs_blocks, :else_block
    end

    class ElifClause < AstNode
      setup :condition, :block
    end

    class ElseClause < AstNode
      setup :block
    end
  end
end
