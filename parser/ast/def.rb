module StoutLang
  module Ast
    class Def < AstNode
      def initialize(name, args, block=nil, parse_node=nil)
        @name = name
        @args = args
        @block = block
      end
    end
  end
end
