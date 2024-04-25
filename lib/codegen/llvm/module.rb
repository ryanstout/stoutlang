module LLVM
  module C
    # attach_function :link_modules, :LLVMLinkModules, [:pointer, :pointer], :int

    # LLVMNamedMDNodeRef 	LLVMGetOrInsertNamedMetadata (LLVMModuleRef M, const char *Name, size_t NameLen)
    attach_function :LLVMGetOrInsertNamedMetadata, [:pointer, :string, :size_t], :pointer
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
