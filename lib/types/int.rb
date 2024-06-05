require 'types/base_type'

module StoutLang
  class Int < BaseType
    def self.type
      Type.new("Int")
    end

    def codegen(compile_jit, mod, func, bb)
      LLVM::Int
    end
  end

  class Int32 < BaseType
    def self.type
      Type.new("Int32")
    end

    def codegen(compile_jit, mod, func, bb)
      LLVM::Int32
    end
  end

  class Int64 < BaseType
    def self.type
      Type.new("Int64")
    end

    def codegen(compile_jit, mod, func, bb)
      LLVM::Int64
    end
  end

end
