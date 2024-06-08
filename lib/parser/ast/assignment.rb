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

        @var = LocalVar.new(@identifier.name, self.expression.type)
        make_children!(@var)

        self.expression = self.expression.resolve
        register_in_scope(identifier.name, @var)
      end

      def run
        expression.run
      end

      def codegen(compile_jit, mod, func, bb)
        # Assign the expression's codegen to the ir for the LocalVar.
        # Any time you use this reference, the LLVM will reference the original
        # variable
        var_ir = expression.codegen(compile_jit, mod, func, bb)

        @var.ir = var_ir
      end
    end
  end
end
