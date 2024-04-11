require 'types/base_type'

module StoutLang
  class Str < BaseType
    def codegen(mod, func, bb)
      LLVM::Pointer(LLVM::Int8)
    end
  end
end
