require 'ffi'

module LLVMString
  extend FFI::Library
  ffi_lib FFI::Library::LIBC

  # Assuming the string is null-terminated, we can use this to read it
  attach_function :string_from_ptr, :strdup, [:pointer], :string
end
