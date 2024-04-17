# ruby-llvm doesn't expose dibuilder, so we add it here:

require 'ffi'
FFI::DynamicLibrary::SEARCH_PATH.unshift(`brew --prefix llvm@17`.strip + "/lib")

require 'llvm'
require 'llvm/core'



module LLVM::C
  # extend FFI::Library
  # ffi_lib ["libLLVM-17.so.1", "libLLVM.so.17", "LLVM-17"]

  attach_function :LLVMCreateDIBuilder, [:pointer], :pointer

  attach_function :LLVMDIBuilderFinalize, [:pointer], :void

  attach_function :LLVMDIBuilderCreateFile, [:pointer, :string, :size_t, :string, :size_t], :pointer

  attach_function :LLVMDIBuilderCreateCompileUnit, [:pointer, :uint, :pointer, :string, :size_t, :bool, :string, :size_t, :uint, :string, :size_t, :uint, :uint, :bool, :bool, :string, :size_t, :string, :size_t], :pointer

  attach_function :LLVMDIBuilderCreateFunction, [:pointer, :pointer, :string, :string, :pointer, :uint, :pointer, :bool, :bool, :uint, :bool, :bool, :pointer, :uint], :pointer

  enum :LLVMDWARFEmissionKind, [
    :LLVMDWARFEmissionNone, 0,
    :LLVMDWARFEmissionFull, 1,
    :LLVMDWARFEmissionLineTablesOnly, 2
  ]

  # You would continue defining other necessary functions here
end

class DIBuilder
  def initialize(mod)
    @mod = mod
    @dibuilder_ptr = LLVM::C::LLVMCreateDIBuilder(mod)
  end

  def create_file(filepath)
    path = Pathname.new(filepath)
    filename = path.basename.to_s
    directory = path.dirname.to_s

    # Create the file descriptor in LLVM's debug info
    LLVM::C::LLVMDIBuilderCreateFile(@dibuilder_ptr, filename, filename.size, directory, directory.size)
  end

  def create_compile_unit(file_path)
    lang = 0x0002 # Dwarf language code (C's for now)
    file_ref = create_file(file_path)
    producer = "StoutLang"
    producer_len = producer.length
    is_optimized = true
    flags = ""
    flags_len = flags.length
    runtime_ver = 1
    split_name = ""
    split_name_len = split_name.length
    emission_kind = 1
    dwo_id = 0
    split_debug_inlining = false
    debug_info_for_profiling = false
    sys_root = ""
    sys_root_len = sys_root.length
    sdk = ""
    sdk_len = sdk.length

    compilation_unit = LLVM::C::LLVMDIBuilderCreateCompileUnit(
      @dibuilder_ptr, lang, file_ref, producer, producer_len, is_optimized,
      flags, flags_len, runtime_ver, split_name, split_name_len,
      emission_kind, dwo_id, split_debug_inlining, debug_info_for_profiling,
      sys_root, sys_root_len, sdk, sdk_len
    )

  end

  # Needs to be called when we're done building
  def finalize
    LLVM::C::LLVMDIBuilderFinalize(@dibuilder_ptr)
  end
end
