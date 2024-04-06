module StoutLang
  module Ast
    class Identifier < AstNode
      attr_reader :name
      setup :name

      def run
        identified = lookup_identifier(name)

        if identified
          identified.run
        else
          raise "Identifier #{name} not found"
        end
      end

      def codegen(mod, bb)
        identified = lookup_identifier(name)

        if identified
          identified.codegen(mod, bb)
        else
          raise "Identifier #{name} not found"
        end
      end
    end
  end
end
