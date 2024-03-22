module StoutLang
  module Ast
    class Block < AstNode
      def initialize(expressions, parse_node=nil)
        @expressions = expressions
      end
    end
  end
end
