module StoutLang
  module Ast
    class FunctionCall < AstNode
      def initialize(name, args, parse_node=nil)
        @name = name
        @args = args
        @parse_node = parse_node
      end

      def inspect_always_wrap?
        true
      end
    end
  end
end
