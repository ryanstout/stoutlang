module StoutLang
  module Ast
    class Assignment < AstNode
      setup :identifier, :expression, :type_sig

      def inspect_internal(indent=0)
        "#{@identifier.name} = #{@expression.inspect(indent)}"
      end

      def prepare
        expression.prepare
        self.type_sig.prepare if self.type_sig

        # register_in_scope(identifier.name, self)

        self.expression = self.expression.resolve
      end

      def run
        expression.run
      end

      def codegen(compile_jit, mod, func, bb)
        var = expression.codegen(compile_jit, mod, func, bb)
        register_in_scope(identifier.name, var)
        var
      end
    end
  end
end
