require "types/base_type"
require "llvm/core"

module StoutLang
  class NilType < BaseType
    setup # no args

    def codegen(compile_jit, mod, func, bb)
      LLVM::Type.void
    end
  end
end
