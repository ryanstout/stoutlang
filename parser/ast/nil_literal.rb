module StoutLang
  module Ast
    class NilLiteral < AstNode
      def initialize(parse_node=nil)
        @parse_node = nil
      end
    end
  end
end
