module StoutLang
  module Ast
    class Macro < AstNode
      def initialize(name, args, block=nil, parse_node=nil)
        @name = name
        @args = args
        @block = block
        @parse_node = parse_node
      end
    end
  end
end
