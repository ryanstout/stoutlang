module StoutLang
  module Ast
    class CPrototype < AstNode
      attr_accessor :name, :args
      attr_accessor :ir

      def initialize(name, args)
        @name = name
        @args = args
      end



      def mangled_name
        name
      end
    end
  end
end
