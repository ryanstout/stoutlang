module StoutLang
  class StructConstructor
    # The LLVM::Struct, and the Arg's for the constructor function
    def initialize(struct_ir, init_func)
      @struct_ir = struct_ir

      @init_func = init_func
    end

    # Codegens an malloc, then a call to the associated init function
    # TODO: with some analysis, we can probably do stack allocations a lot of the time.
    def codegen(compile_jit, mod, func, bb)
      return
      arg_types = @constructor_args.map do |carg|
        carg.type_sig.codegen(compile_jit, mod, func, bb)
      end

      # Alloc's the struct on the heap, then calls the init function passing in the struct and
      # any arguments
      malloc = mod.functions["malloc"]

      # Read the struct size
      size = mod.functions[Struct::SIZE_METHOD_NAME]
      struct_size = bb.call(size, [], "struct_size")

      # Malloc space based on struct_size
      struct_ptr = bb.call(malloc, struct_size, "struct_malloc")

      # Call init passing in the struct pointer as the first argument
      args = [struct_ptr] + arg_types

      init_func_call = FunctionCall.new('init', args)


      return bb.call(@init_func, args, "struct_init")
    end
  end
end
