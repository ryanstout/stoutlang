module StoutLang
  module Ast
    class List < AstNode
      def initialize(elements, parse_node=nil)
        @elements = elements
        @parse_node = parse_node
      end
    end
  end
end