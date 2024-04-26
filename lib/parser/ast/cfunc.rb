require 'parser/ast/def'

module StoutLang
  module Ast
    class CFunc < Def
       # doesn't take a block like Def does
      setup :name, :args, :varargs_enabled, :return_type

      def prepare

      end

      def codegen(compile_jit, mod, func, bb)
        # sprintf = mod.functions.add('sprintf', [LLVM::Pointer(LLVM::Int8), LLVM::Pointer(LLVM::Int8)], LLVM::Int, varargs: true)

        # TODO: right now we're just adding them to the global namespace, we should scope them to the Lib

        arg_types = args.map do |arg|
          arg.type_sig.codegen(compile_jit, mod, func, bb)
        end

        return_type = self.return_type.codegen(compile_jit, mod, func, bb)

        # Create the function
        func = mod.functions.add(name, arg_types, return_type, varargs: @varargs_enabled)

        func
      end
    end
  end
end
