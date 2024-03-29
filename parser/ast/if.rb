module StoutLang
  module Ast
    class If < AstNode
      def initialize(condition, if_block, elifs_blocks, else_block, parse_node=nil)
        @condition = condition
        @if_block = if_block
        @elifs_blocks = elifs_blocks
        @else_block = else_block
        @parse_node = parse_node
      end
    end

    class ElifClause < AstNode
      def initialize(condition, block, parse_node=nil)
        @condition = condition
        @block = block
        @parse_node = parse_node
      end
    end

    class ElseClause < AstNode
      def initialize(block, parse_node=nil)
        @block = block
        @parse_node = parse_node
      end
    end
  end
end
