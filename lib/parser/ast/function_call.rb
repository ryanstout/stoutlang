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

      def codegen(mod, func, bb)
        if name == "%>"
          method_call = lookup_identifier("%>")

          arg = args[0].codegen(mod, func, bb)

          zero = LLVM.Int(0)

          # Read here what GetElementPointer (gep) means http://llvm.org/releases/3.2/docs/GetElementPtr.html
          # Convert [13 x i8]* to i8  *...
          cast210 = bb.gep arg, [zero, zero], 'cast210'
          # Call puts function to write out the string to stdout.

          bb.call method_call.ir, cast210
          nil
        else
          method_call = lookup_identifier(name)

          unless method_call
            raise "Unable to find function #{name} in scope"
          end

          bb.call method_call.ir
        end
      end
    end
  end
end
