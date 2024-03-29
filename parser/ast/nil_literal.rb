module StoutLang
  module Ast
    class NilLiteral < AstNode
      def initialize(parse_node=nil)
        @parse_node = parse_node
      end
    end
  end
end
