require 'parser/ast/def'

module StoutLang
  module Ast
    class CFunc < Def
       # doesn't take a block like Def does
      setup :name, :args, :varargs_enabled, :return_type
      attr_accessor :ir

      def prepare
        args.each(&:prepare)
        self.return_type.prepare if self.return_type

        # Currently we register in the scope above the lib
        # TODO: depending on how we handle resolution and imports, we may want to change this.

        # Find the parent lib
        parent_lib = parent_scope

        unless parent_lib.is_a?(Lib)
          raise "CFunc must be defined within a Lib: #{self.inspect}"
        end


        parent_lib.parent_scope.register_in_scope(name, self)
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

        self.ir = func

        func
      end
    end
  end
end
