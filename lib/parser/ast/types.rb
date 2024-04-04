module StoutLang
  module Ast
    class Type < AstNode
      setup :name

      def run
        self
      end
    end

    class TypeVariable < AstNode
      setup :name

      def run
        self
      end
    end

    class TypeSig < AstNode
      setup :type_val

      def run
        self
      end
    end
  end
end
