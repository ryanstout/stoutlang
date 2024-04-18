require 'types/base_type'

module StoutLang
  class Bool < BaseType
    def codegen(compile_jit, mod, func, bb)
      LLVM::Int1
    end
  end
end
