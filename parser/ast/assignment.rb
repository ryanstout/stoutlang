module StoutLang
  module Ast
    class Assignment < AstNode
      def initialize(identifier, expression, type_sig, parse_node=nil)
        @identifier = identifier
        @expression = expression
        @type_sig = type_sig
        @parse_node = parse_node
      end

      def inspect_internal(indent=0)
        "#{@identifier.name} = #{@expression.inspect(indent)}"
      end
    end
  end
end
