# Singleton class to write metadata into a module
require 'codegen/llvm/module'


module StoutLang
  class Metadata
    def self.add(llvm_module, metadata_name, metadata_str)
      ctx = LLVM::C.get_module_context(llvm_module)
      metadata_values = LLVM::C.md_string_in_context(ctx, metadata_str, metadata_str.size)

      ptrs = FFI::MemoryPointer.new(:pointer, 1)
      ptrs.put_pointer(0 * FFI::Pointer.size, metadata_values)

      md_node = LLVM::C.md_node_in_context(ctx, ptrs, 1)

      LLVM::C.add_named_metadata_operand(llvm_module, metadata_name, md_node)
    end

    def self.read(llvm_module, metadata_name)
      # Return an array of all metadata strings for the metadata_name

      num_operands = LLVM::C.get_named_metadata_num_operands(llvm_module, metadata_name)

      operands = FFI::MemoryPointer.new(:pointer, num_operands)
      LLVM::C.get_named_metadata_operands(llvm_module, metadata_name, operands)

      metadata_strings = []
      num_operands.times do |i|
        operand_ptr = operands[i].read_pointer # Read the pointer from the memory block
        operand = LLVM::C.get_operand(operand_ptr, 0)
        str_len = FFI::MemoryPointer.new(:pointer, 1)
        md_str = LLVM::C.get_md_string(operand, str_len)
        metadata_strings << md_str
      end

      metadata_strings
    end
  end
end
