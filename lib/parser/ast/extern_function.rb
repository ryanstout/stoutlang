module StoutLang
  module Ast
    class ExternFunc < AstNode
      attr_accessor :ir, :args

      def initialize(ir, args)
        @ir = ir
        @args = args
      end
    end
  end
end
