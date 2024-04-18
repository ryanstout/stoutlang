module LLVM
  module C
    # attach_function :link_modules, :LLVMLinkModules, [:pointer, :pointer], :int
  end
  class Module
    def initialize(name, context=nil)
      if context
        @ptr = C.module_create_with_name_in_context(name, context)
      else
        @ptr = C.module_create_with_name(name)
      end
    end
  end
end
