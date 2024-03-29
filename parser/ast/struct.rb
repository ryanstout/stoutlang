module StoutLang
  module Ast
    class Struct < AstNode
      def initialize(name, block, parse_node=nil)
        @name = name
        @block = block
        @parse_node = parse_node
      end
    end
  end
end
