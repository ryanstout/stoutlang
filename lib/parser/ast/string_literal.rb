module StoutLang
  module Ast
    class StringLiteral < AstNode
      setup :value

      def run
        value
      end
    end

    class StringInterpolation < AstNode
      setup :expressions
    end
  end
end
