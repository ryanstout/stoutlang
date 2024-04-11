module StoutLang
  module Ast
    class ShellStringLiteral < AstNode
      setup :value, :language

      def run
        value.map do |v|
          if v.is_a?(String)
            v
          else
            v.run
          end
        end.join("")
      end

      def find_parent_assignement
        parent = self.parent
        while parent
          if parent.is_a?(Assignment)
            return parent
          elsif parent.is_a?(Scope)
            return nil
          end
          parent = parent.parent
        end
        return nil
      end

      def codegen(mod, func, bb)
        raise "Not implemented"
      end
    end
  end
end
