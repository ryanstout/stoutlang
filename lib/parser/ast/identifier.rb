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

      def type
        resolved = self.resolve
        puts "RESOLVED: #{resolved.inspect}"
        resolved.type
      end

      # For identifiers that resolve to a Def, return a FunctionCall, for other identifiers,
      # keep the identifier.
      def resolve
        # This may not be a function, but will match either a zero arg function or something else
        identified = lookup_function(name, [])

        unless identified
          raise "Identifier #{name} not found"
        end

        if identified.is_a?(StoutLang::Ast::Def)
          # Create a FunctionCall and assign it to self
          func_call = StoutLang::Ast::FunctionCall.new(name, [])
          # Assign self as the parent scope
          func_call.parent = self
          # Assign the function call to self
          return func_call
        else
          return identified
        end
      end

      def codegen(compile_jit, mod, func, bb)
        identified = lookup_identifier(name)

        if identified.is_a?(StoutLang::Ast::Def)
          # raise "The Identifier should have been replaced with a FunctionCall by now."
          # TODO: Also handle CPrototype

          # Create a FunctionCall and codegen it

          func_call = StoutLang::Ast::FunctionCall.new(name, [])
          # Assign self as the parent scope
          func_call.parent = self
          return func_call.codegen(compile_jit, mod, func, bb)
        elsif identified.is_a?(Arg)
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
