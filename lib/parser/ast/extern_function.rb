module StoutLang
  module Ast
    class ExternFunc < AstNode
      attr_accessor :ir

      def initialize(ir)
        @ir = ir
      end
    end
  end
end
