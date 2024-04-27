require 'types/base_type'

module StoutLang
  class BlockType < BaseType
    def codegen(compile_jit, mod, func, bb)
      raise "Not implemented"
    end
  end
end
