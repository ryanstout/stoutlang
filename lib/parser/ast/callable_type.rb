module StoutLang
  module Ast
    class CallableType < AstNode
      setup :arg_types, :return_type

      def type_ir_codegen(compile_jit, mod, func, bb)
        ret = return_type.codegen(compile_jit, mod, func, bb)
        args = self.arg_types.map { |arg_type| arg_type.codegen(compile_jit, mod, func, bb) }
        func_type = LLVM::Type.function(
          args,
          ret
        )

        return func_type
      end

      def codegen(compile_jit, mod, func, bb)
        # Codegen the type for an function in LLVM that takes arg_types and returns return_type
        func_type = self.type_ir_codegen(compile_jit, mod, func, bb)

        # Opaque pointers mean we only get back a `ptr %block``
        return LLVM::Pointer(func_type)
      end

      def self.ast_props
        @ast_props || superclass.ast_props
      end

      def mangled_name
        mangled_args = self.arg_types.map do |arg_type|
          arg_type.mangled_name
        end.join(',')
        "(#{mangled_args})->#{self.return_type.mangled_name}"
      end
    end
  end
end
