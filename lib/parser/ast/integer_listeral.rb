module StoutLang
  module Ast
    class IntegerLiteral < AstNode
      setup :value

      def run
        value
      end
    end
  end
end
