module StoutLang
  module Ast
    class Block < AstNode
      def initialize(expressions, parse_node=nil)
        @expressions = expressions
        @parse_node = parse_node
      end
    end
  end
end
