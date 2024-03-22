module StoutLang
  module Ast
    class If < AstNode
      def initialize(condition, if_block, elifs_blocks, else_block)
        @condition = condition
        @if_block = if_block
        @elifs_blocks = elifs_blocks
        @else_block = else_block
      end
    end

    class ElifClause < AstNode
      def initialize(condition, block)
        @condition = condition
        @block = block
      end
    end

    class ElseClause < AstNode
      def initialize(block)
        @block = block
      end
    end
  end
end
