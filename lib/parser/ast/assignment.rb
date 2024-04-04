module StoutLang
  module Ast
    class Assignment < AstNode
      setup :identifier, :expression, :type_sig

      def inspect_internal(indent=0)
        "#{@identifier.name} = #{@expression.inspect(indent)}"
      end

      def prepare
        expression.prepare

        register_in_scope(identifier.name, self)
      end

      def run
        expression.run
      end
    end
  end
end
