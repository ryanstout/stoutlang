module StoutLang
  module Ast
    class Identifier < AstNode
      attr_reader :name
      setup :name
    end
  end
end
