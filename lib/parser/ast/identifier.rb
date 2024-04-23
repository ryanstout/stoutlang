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

      def codegen(compile_jit, mod, func, bb)
        identified = lookup_identifier(name)

        if identified.is_a?(StoutLang::Ast::Def)
          # Create a FunctionCall and codegen it

          func_call = StoutLang::Ast::FunctionCall.new(name, [])
          # Assign self as the parent scope
          func_call.parent = self
          func_call.codegen(compile_jit, mod, func, bb)
        elsif identified
          identified#.codegen(mod, func, bb)
        else
          raise "Identifier #{name} not found for #{inspect}"
        end
      end
    end
  end
end
