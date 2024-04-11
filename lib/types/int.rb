require 'types/base_type'

module StoutLang
  class Int < BaseType
    def codegen(mod, func, bb)
      LLVM::Int
    end
  end
end
