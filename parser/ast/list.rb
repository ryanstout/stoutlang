module StoutLang
  module Ast
    class List < AstNode
      def initialize(elements, parse_node=nil)
        @elements = elements
      end
    end
  end
end
