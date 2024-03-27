module StoutLang
  module Ast
    class Property < AstNode
      def initialize(name, type_sig, parse_node=nil)
        @name = name
        @type_sig = type_sig
      end
    end
  end
end
