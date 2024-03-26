module StoutLang
  module Ast
    class Type < AstNode
      def initialize(name, parse_node=nil)
        @name = name
      end
    end

    class TypeVariable < AstNode
      def initialize(name, parse_node=nil)
        @name = name
      end
    end

    class TypeSig < AstNode
      def initialize(type_val, parse_node=nil)
        @type_val = type_val
      end
    end
  end
end
