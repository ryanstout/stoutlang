module StoutLang
  module Ast
    class StringLiteral < AstNode
      setup :value

      def run
        value.map do |v|
          if v.is_a?(String)
            v
          else
            v.run
          end
        end.join("")
      end
    end

    class StringInterpolation < AstNode
      setup :block

      def prepare
        block.prepare
      end

      def run
        block.run.to_s
      end
    end
  end
end
