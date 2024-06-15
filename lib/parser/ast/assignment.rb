module StoutLang
  module Ast
    class Assignment < AstNode
      setup :identifier, :expression, :type_sig

      def inspect_internal(indent = 0)
        "#{@identifier.name} = #{@expression.inspect(indent)}"
      end

      def type
        expression.type
      end

      def prepare
        expression.prepare

        if identifier.is_a?(InstanceVar)
          self_local = lookup_identifier("@")
          self.type_sig = TypeSig.new(type_val = self_local.type)
        end

        self.type_sig.prepare if self.type_sig

        @var = LocalVar.new(@identifier.name, self.expression.type)
        make_children!(@var)

        register_in_scope(identifier.name, @var)

        self.expression = self.expression.resolve
      end

      def run
        expression.run
      end

      def codegen(compile_jit, mod, func, bb)
        # Assign the expression's codegen to the ir for the LocalVar.
        # Any time you use this reference, the LLVM will reference the original
        # variable

        var_ir = expression.codegen(compile_jit, mod, func, bb)

        if identifier.is_ivar?
          # Lookup self, should be a struct
          self_local = lookup_identifier("@")
          struct_type = self_local.type.resolve

          property_pointer = identifier.resolve.codegen_get_pointer(compile_jit, mod, func, bb)

          bb.store(var_ir, property_pointer)
        else
          @var.ir = var_ir

          var_ir
        end
      end
    end
  end
end
