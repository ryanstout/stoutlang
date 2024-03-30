module StoutLang
  module Ast
    class Type < AstNode
      setup :name
    end

    class TypeVariable < AstNode
      setup :name
    end

    class TypeSig < AstNode
      setup :type_val
    end
  end
end
