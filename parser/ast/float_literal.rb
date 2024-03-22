module StoutLang
  module Ast
    class FloatLiteral < AstNode
      def initialize(value, parse_node=nil)
        @value = value
        @parse_node = parse_node
      end
    end
  end
end
