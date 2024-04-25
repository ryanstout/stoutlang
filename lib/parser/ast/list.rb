module StoutLang
  module Ast
    class List < AstNode
      setup :elements

      def prepare
        self.elements = elements.map(&:resolve)
        elements.each(&:prepare)
      end
    end
  end
end
