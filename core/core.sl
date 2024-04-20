# We implement as much core functionality in StoutLang as possible, core
# provides a lot of the core functionality of the language.

r```
# Export %> print
cputs = mod.functions.add('puts', [LLVM.Pointer(LLVM::Int8)], LLVM::Int32) do |function, string|
  function.add_attribute :no_unwind_attribute
  string.add_attribute :no_capture_attribute
end

register_in_scope('puts', ExternFunc.new(cputs))

# Export sprintf and malloc
sprintf = mod.functions.add('sprintf', [LLVM::Pointer(LLVM::Int8), LLVM::Pointer(LLVM::Int8)], LLVM::Int, varargs: true)
register_in_scope('sprintf', ExternFunc.new(sprintf))
malloc = mod.functions.add('malloc', [LLVM::Int], LLVM::Pointer(LLVM::Int8))
register_in_scope('malloc', ExternFunc.new(malloc))
```

def %>(str: Str) -> Int {
  puts(str)
}

def +(a: Int, b: Int) -> Int {
  r```
  temp = bb.add(func.params[0], func.params[1], 'add')
  return temp
  ```
}


def -(a: Int, b: Int) -> Int {
  r```
  temp = bb.sub(func.params[0], func.params[1], 'sub')
  return temp
  ```
}

def ==(a: Int, b: Int) -> Bool {
  r```
  temp = bb.icmp(:eq, func.params[0], func.params[1], 'eq')
  return temp
  ```
}

def to_s(a: Int) -> Str {
  r```
  format_str_ptr = LLVM::ConstantArray.string("%d")

  format_str = mod.globals.add(format_str_ptr, 'format_str') do |var|
    var.linkage = :private
    var.global_constant = true
    var.unnamed_addr = true
    var.initializer = format_str_ptr
  end

  
  # Allocate 30 byte string
  temp_size = LLVM::Int(30)
  
  # Prepare arguments for sprintf to calculate required length
  # null_ptr = LLVM::Int(0).int_to_ptr(LLVM::Pointer(LLVM::Int8))
  # temp_size_call = bb.call(sprintf, null_ptr, format_str, func.params[0])
  # temp_size = bb.add(temp_size_call, LLVM::Int(1))  # Properly add 1 to the result of the call
  
  # Allocate buffer based on the computed size
  malloc = lookup_identifier('malloc').ir
  str_ptr = bb.call(malloc, temp_size)

  # Call sprintf again to actually print the integer
  sprintf = lookup_identifier('sprintf').ir
  bb.call(sprintf, str_ptr, format_str, func.params[0])
  

  # Cast str_ptr to a generic pointer (i8*) and return it
  return bb.bit_cast(str_ptr, LLVM::Pointer(LLVM::Int8))
  ```
}
