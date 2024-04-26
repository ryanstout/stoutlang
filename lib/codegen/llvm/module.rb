module LLVM
  module C
    # attach_function :link_modules, :LLVMLinkModules, [:pointer, :pointer], :int

    # LLVMNamedMDNodeRef 	LLVMGetOrInsertNamedMetadata (LLVMModuleRef M, const char *Name, size_t NameLen)
    attach_function :LLVMGetOrInsertNamedMetadata, [:pointer, :string, :size_t], :pointer

    # LLVMValueRef 	LLVMAddAlias2 (LLVMModuleRef M, LLVMTypeRef ValueTy, unsigned AddrSpace, LLVMValueRef Aliasee, const char *Name)
    attach_function :add_alias2, :LLVMAddAlias2, [:pointer, :pointer, :uint, :pointer, :string], :pointer


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
