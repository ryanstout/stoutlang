module StoutLang
  module Ast
    class FunctionCall < AstNode
      OPERATORS = ['+', '-', '*', '/', '||', '&&', '|', '&']
      setup :name, :args

      def inspect_always_wrap?
        true
      end

      def run
        if OPERATORS.include?(name)
          args.map(&:run).reduce(name)
        else
          raise "Not implemented"
        end
      end
    end
  end
end
