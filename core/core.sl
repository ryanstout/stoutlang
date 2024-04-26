# We implement as much core functionality in StoutLang as possible, core
# provides a lot of the core functionality of the language.

lib LibC {
  cfunc puts(str: Str) -> Int
  cfunc sprintf(str: Str, format: Str, ...) -> Int
  cfunc malloc(size: Int) -> Str
  
}

def %>(str: Str) -> Int {
  puts(str)
  0
}


# def times(num: Int, block: Int) -> Int {
#   r```

#   # Create a new basic block for the loop
#   loop_block = func.basic_blocks.append('loop')
#   after_block = func.basic_blocks.append('after')

#   # Create an incrementer variable
#   i = bb.alloca(LLVM::Int32, "__incrementer")

#   bb.br(loop_block)
#   loop_block.build do |b|
#     # Load the incrementer
#     inc = b.load(i, 'inc')

#     # Compare the incrementer to the number
#     cmp = b.icmp(:slt, inc, func.params[0], 'cmp')

#     # Codegen the block
#     block.codegen(compile_jit, mod, func, b)

#     # Create a conditional branch
#     b.cond(cmp, loop_block, after_block)
#   end

#   bb.position_at_end(after_block)

#   ```
# }

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

# TODO: once we have generics, this can be implemented as a generic function
def to_s_i64(a: Int64) -> Str {
  r```
  format_str_ptr = LLVM::ConstantArray.string("%ld")

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
