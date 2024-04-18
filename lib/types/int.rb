require 'types/base_type'

module StoutLang
  class Int < BaseType
    def codegen(compile_jit, mod, func, bb)
      LLVM::Int
    end
  end
end
