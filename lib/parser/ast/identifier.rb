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

      def prepare
      end

      # For identifiers that resolve to a Def, return a FunctionCall, for other identifiers,
      # keep the identifier.
      def resolve
        identified = lookup_function(name)

        if identified.is_a?(StoutLang::Ast::Def)
          # Create a FunctionCall and assign it to self
          func_call = StoutLang::Ast::FunctionCall.new(name, [])
          # Assign self as the parent scope
          func_call.parent = self
          # Assign the function call to self
          return func_call
        else
          return self
        end
      end

      def codegen(compile_jit, mod, func, bb)
        identified = lookup_identifier(name)

        if identified.is_a?(StoutLang::Ast::Def)
          # TODO: Also handle ExternFunction

          # Create a FunctionCall and codegen it

          func_call = StoutLang::Ast::FunctionCall.new(name, [])
          # Assign self as the parent scope
          func_call.parent = self
          return func_call.codegen(compile_jit, mod, func, bb)
        elsif identified.is_a?(DefArg)
          identified.codegen(compile_jit, mod, func, bb)
        elsif identified
          identified
          # identified#.codegen(mod, func, bb)
        else
          raise "Identifier #{name} not found for #{inspect}"
        end
      end
    end
  end
end
