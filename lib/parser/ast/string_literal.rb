module StoutLang
  module Ast
    class StringLiteral < AstNode
      setup :value
    end

    class StringInterpolation < AstNode
      setup :expressions
    end
  end
end
