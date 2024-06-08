module StoutLang
  module Ast
    class Assignment < AstNode
      setup :identifier, :expression, :type_sig

      def inspect_internal(indent=0)
        "#{@identifier.name} = #{@expression.inspect(indent)}"
      end

      def type
        expression.type
      end

      def prepare
        expression.prepare
        self.type_sig.prepare if self.type_sig

        var = LocalVar.new(@identifier.name, self.expression.type)
        make_children!(var)
        register_in_scope(identifier.name, var)

        self.expression = self.expression.resolve
      end

      def run
        expression.run
      end

      def codegen(compile_jit, mod, func, bb)
        var_ir = expression.codegen(compile_jit, mod, func, bb)

        # Lookup the local
        var = lookup_identifier(identifier.name)

        var.ir = var_ir
        # register_in_scope(identifier.name, var)
        var.codegen(compile_jit, mod, func, bb)
      end
    end
  end
end
