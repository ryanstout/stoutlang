module StoutLang
  module Ast
    class Macro < AstNode
      setup :name, :args, :block
    end
  end
end
