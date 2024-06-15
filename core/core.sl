# We implement as much core functionality in StoutLang as possible, core
# provides a lot of the core functionality of the language.

# Expose some LibC functions we need for now
lib LibC {
  cfunc puts(str: Str) -> Int
  cfunc sprintf(str: Str, format: Str, ...) -> Int
  cfunc malloc(size: Int) -> Str
  cfunc strdup(str: Str) -> Str
  
}

def %>(str: Str) -> Int {
  puts(str)
  0
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

def *(a: Int, b: Int) -> Int {
  r```
  temp = bb.mul(func.params[0], func.params[1], 'mul')
  return temp
  ```
}

def /(a: Int, b: Int) -> Int {
  r```
  temp = bb.sdiv(func.params[0], func.params[1], 'div')
  return temp
  ```
}

def ==(a: Int, b: Int) -> Bool {
  r```
  temp = bb.icmp(:eq, func.params[0], func.params[1], 'eq')
  return temp
  ```
}

# Run the block `num` times
def times(num: Int, block: Int -> Int) -> Int {
  # The following is in SSA style, this produces more optimzed machine
  # code than the non-SSA version (using alloca).

  i = 0

  r```
  yield_call = Parser.new.parse('yield(i)', wrap_root: false)
  yield_call = yield_call.expressions[0]
  
  yield_call.assign_parent!(self).make_children!(yield_call.args)
  yield_call.prepare
  
  entry = func.basic_blocks.first
  loop_block = func.basic_blocks.append("loop")
  body = func.basic_blocks.append("body")
  end_block = func.basic_blocks.append("end")

  bb.br(loop_block)

  i = nil
  loop_block.build do |b|
    # the value of i depends on the basic block we are coming from.
    i = b.phi(LLVM::Int, {entry => LLVM::Int(0)}, 'i')

    # Use the phi instruction as i and not the LocalVar above (use the LocalVar
    # to register it)
    lookup_identifier('i').ir = i
    num = lookup_identifier('num').ir
    cond = b.icmp(:slt, i, num)
    b.cond(cond, body, end_block)
  end


  body.build do |b|
    # Yield to the block
    yield_call.codegen(compile_jit, mod, func, b)

    # Increment i
    i_next = b.add(i, LLVM::Int(1), 'i.next')

    # Add another branch to the phi node
    i.add_incoming({body => i_next})

    b.br(loop_block)
  end

  end_block.build do |b|
    b.ret(LLVM::Int(0))
  end
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
