module StoutLang
  class Import
    # Import types and functions from a compile bitcode module. Compile it first
    # if it's not already compiled
    def codegen(compile_jit, mod, func, bb, import_call)
      # Read the path from the first argument
      path = import_call.args[0].run
      puts "Import Path: #{path}"

      original_module = LLVM::Module.parse_bitcode("#{path}.bc")

      # compile_jit << original_module
      # Iterate over each function in the original module and create externs
      original_module.functions.each do |function|
        # unless function.intrinsic? # Skip intrinsic functions, only focus on user-defined ones
        # Duplicate the function type but mark it as an external (declare)
        if function.name == 'main'
          original_module.functions.delete(function)
        end

        next if ['main', '==', '+', '-'].include?(function.name)
        extern_function = mod.functions.add(
          function.name,
          function.params.map(&:type), # Map params to their types
          function.type.return_type,
          # function.type.vararg? # Preserve var_arg status
          )

          # Add the function to the scope
          import_call.register_in_scope(function.name, ExternFunc.new(extern_function))

          # end
      end

      # original_module.link_into(mod)
    end

  end
end
