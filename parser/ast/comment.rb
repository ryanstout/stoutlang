module StoutLang
  module Ast
    class Comment < AstNode
      def initialize(comment, parse_node=nil)
        @comment = comment
        @parse_node = parse_node
      end
    end
  end
end
