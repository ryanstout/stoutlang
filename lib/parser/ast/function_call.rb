module StoutLang
  module Ast
    class FunctionCall < AstNode
      OPERATORS = ['+', '-', '*', '/', '||', '&&', '|', '&']
      setup :name, :args

      def inspect_always_wrap?
        true
      end

      def prepare
      end

      def run
        if OPERATORS.include?(name)
          args.map(&:run).reduce(name)
        else
          raise "Not implemented"
        end
      end

      def effects
        if name == 'emit'
          # Emit gets handled directly for now

          # The first argument is the effect
          effect_type = args[0].run

          return [effect_type]
        else
          # Find the function in scope, and return its effects
          function = lookup_identifier(name)


          if function && function.is_a?(Def)
            function.effects.uniq
          else
            []
          end
        end
      end

      def codegen(compile_jit, mod, func, bb)
        method_call = lookup_identifier(name)

        unless method_call
          raise "Unable to find function #{name} in scope"
        end

        args = self.args.map do |arg|
          arg.codegen(compile_jit, mod, func, bb)
        end

        return bb.call method_call.ir, *args, assignment_name || 'temp'
      end
    end
  end
end
