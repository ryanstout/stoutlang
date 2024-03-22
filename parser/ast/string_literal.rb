module StoutLang
  module Ast
    class StringLiteral < AstNode
      def initialize(value, parse_node=nil)
        @value = value
        @parse_node = parse_node
      end
    end

    class StringInterpolation < AstNode
      def initialize(expressions, parse_node=nil)
        @expressions = expressions
        @parse_node = parse_node
      end
    end
  end
end
