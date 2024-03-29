module StoutLang
  module Ast
    class Property < AstNode
      def initialize(name, type_sig, parse_node=nil)
        @name = name
        @type_sig = type_sig
        @parse_node = parse_node
      end
    end
  end
end
