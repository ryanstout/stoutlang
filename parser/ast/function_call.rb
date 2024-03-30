module StoutLang
  module Ast
    class FunctionCall < AstNode
      setup :name, :args

      def inspect_always_wrap?
        true
      end
    end
  end
end
