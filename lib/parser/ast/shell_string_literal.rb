module StoutLang
  module Ast
    class ShellStringLiteral < AstNode
      setup :value, :language

      def prepare
        self.value.each do |val|
          val.prepare if val.respond_to?(:prepare)
        end
      end

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

      def codegen(compile_jit, mod, func, bb)
        if language == 'r'
          # ruby -- used for the compiler for now

          # We want to run the string in ruby now
          eval(self.run)

          return
        end

        raise "Not implemented"
      end
    end
  end
end
