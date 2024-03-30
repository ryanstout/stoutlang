module StoutLang
  module Ast
    class IntegerLiteral < AstNode
      setup :value
    end

    def run
      value
    end
  end
end
