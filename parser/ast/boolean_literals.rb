module StoutLang
  module Ast
    class TrueLiteral < AstNode
      def initialize(parse_node=nil)
        @parse_node = parse_node
      end
    end

    class FalseLiteral < AstNode
      def initialize(parse_node=nil)
        @parse_node = parse_node
      end
    end
  end
end
