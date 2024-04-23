require 'types/base_type'

module StoutLang
  class Int < BaseType
    def codegen(compile_jit, mod, func, bb)
      LLVM::Int
    end
  end

  class Int64 < BaseType
    def codegen(compile_jit, mod, func, bb)
      LLVM::Int64
    end
  end

end
