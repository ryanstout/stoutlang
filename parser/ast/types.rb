module StoutLang
  module Ast
    class Type < AstNode
      def initialize(name, parse_node=nil)
        @name = name
        @parse_node = parse_node
      end
    end

    class TypeVariable < AstNode
      def initialize(name, parse_node=nil)
        @name = name
        @parse_node = parse_node
      end
    end

    class TypeSig < AstNode
      def initialize(type_val, parse_node=nil)
        @type_val = type_val
        @parse_node = parse_node
      end
    end
  end
end
