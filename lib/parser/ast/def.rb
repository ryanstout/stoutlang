module StoutLang
  module Ast
    class Def < AstNode
      setup :name, :args, :block

    end

    class DefArg < AstNode
      setup :name, :type_sig
    end
  end
end
