module StoutLang
  module Ast
    class Identifier < AstNode
      attr_reader :name

      def initialize(name, parse_node=nil)
        @name = name
        @parse_node = parse_node
      end
    end
  end
end
