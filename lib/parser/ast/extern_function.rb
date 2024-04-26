module StoutLang
  module Ast
    class ExternFunc < AstNode
      attr_accessor :name, :ir, :args

      def initialize(name, ir, args)
        @name = name
        @ir = ir
        @args = args
      end

      def mangled_name
        name
      end
    end
  end
end
