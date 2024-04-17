# During compilation, all structs and functions are added to a jit as the AST is visited.
# This lets compile time code evaulate in the context of what has been walked before it.
require 'ffi'

module LLVM::OrcJit
  extend FFI::Library

  # We need to load the symbols in the library globally to work around a bug
  # https://github.com/apache/arrow/issues/39695
  ffi_lib_flags(:global)

  ffi_lib ["libLLVM-17.so.1", "libLLVM.so.17", "LLVM-17"]


  typedef :pointer, :LLVMOrcLLJITRef
  typedef :pointer, :LLVMOrcLLJITBuilderRef
  typedef :pointer, :LLVMOrcJITDylibRef
  typedef :pointer, :LLVMOrcThreadSafeModuleRef
  typedef :pointer, :LLVMErrorRef
  typedef :pointer, :LLVMOrcThreadSafeContextRef
  typedef :pointer, :LLVMOrcThreadSafeModuleRef
  typedef :pointer, :LLVMModuleRef

  # Define the LLVM functions we need
  attach_function :LLVMOrcCreateLLJITBuilder, [], :LLVMOrcLLJITBuilderRef
  attach_function :LLVMOrcCreateLLJIT, [:LLVMOrcLLJITRef, :LLVMOrcLLJITBuilderRef], :LLVMErrorRef
  attach_function :LLVMOrcDisposeLLJIT, [:LLVMOrcLLJITRef], :LLVMErrorRef
  attach_function :LLVMOrcLLJITGetMainJITDylib, [:LLVMOrcLLJITRef], :LLVMOrcJITDylibRef
  attach_function :LLVMOrcLLJITAddLLVMIRModule, [:LLVMOrcLLJITRef, :LLVMOrcJITDylibRef, :LLVMOrcThreadSafeModuleRef], :LLVMErrorRef
  attach_function :LLVMOrcCreateNewThreadSafeContext, [], :LLVMOrcThreadSafeContextRef
  attach_function :LLVMOrcCreateNewThreadSafeModule, [:LLVMOrcThreadSafeContextRef, :LLVMModuleRef], :LLVMOrcThreadSafeModuleRef
  attach_function :LLVMDisposeModule, [:LLVMModuleRef], :void
  attach_function :LLVMOrcLLJITGetTripleString, [:pointer], :string
  attach_function :LLVMGetErrorMessage, [:pointer], :string

end

# binding.pry

class Jit
  def initialize
    LLVM.init_jit(true)
    builder = LLVM::OrcJit.LLVMOrcCreateLLJITBuilder()
    @lljit_ptr = FFI::MemoryPointer.new(FFI.type_size(:pointer))
    error = LLVM::OrcJit::LLVMOrcCreateLLJIT(@lljit_ptr, builder)
    if error.null?
      @lljit = @lljit_ptr.read_pointer
      puts "TS: #{LLVM::OrcJit.LLVMOrcLLJITGetTripleString(@lljit_ptr.read_pointer)}--"
    else
      message = LLVM::OrcJit.LLVMGetErrorMessage(error)
      puts "Error: #{message}"
    end
  end

  def dispose
    LLVM::OrcJit::LLVMOrcDisposeLLJIT(@lljit)
  end

  def add_module(module_ptr)
    jd = LLVM::OrcJit::LLVMOrcLLJITGetMainJITDylib(@lljit_ptr.read_pointer)
    puts "HERE1: #{module_ptr.inspect} -- JD: #{jd.inspect}"
    thread_safe_module = create_thread_safe_module(module_ptr)
    # puts "TSM: #{thread_safe_module.inspect}"
    LLVM::OrcJit::LLVMOrcLLJITAddLLVMIRModule(@lljit_ptr.read_pointer, jd, thread_safe_module)
  end

  def run_function(function_name, *args)
    # Look up the function address
    function_address_ptr = FFI::MemoryPointer.new(:uint64)
    error = LLVM::OrcJit.OrcLLJITLookup(@lljit, function_address_ptr, function_name)
    raise "Failed to look up function '#{function_name}': #{LLVM::OrcJit.GetErrorMessage(error)}" if error.to_i != 0
    function_address = function_address_ptr.read_uint64

    # Define the function signature
    function_signature = args.map { |arg| arg.class == Integer ? :int : :pointer }
    function_signature << :int # Return type is always :int in this example

    # Create a function pointer with the looked-up address and signature
    function_ptr = FFI::Function.new(*function_signature, function_address)

    # Call the function with the provided arguments
    result = function_ptr.call(*args)

    result
  end

  def create_thread_safe_module(module_ref)
    # Create a new ThreadSafeContext
    tsc = LLVM::OrcJit.LLVMOrcCreateNewThreadSafeContext

    # Create a new ThreadSafeModule
    tsm = LLVM::OrcJit.LLVMOrcCreateNewThreadSafeModule(tsc, module_ref)

    # Dispose of the original module
    # LLVM::OrcJit.LLVMDisposeModule(module_ref)

    tsm
  end
end

jit = Jit.new
module_ptr = LLVM::Module.new('root').instance_variable_get(:@ptr)
jit.add_module(module_ptr)
