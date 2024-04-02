module StoutLang
  module Ast
    class List < AstNode
      setup :elements

      def prepare
        elements.each(&:prepare)
      end
    end
  end
end
