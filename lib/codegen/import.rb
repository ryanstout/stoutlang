require 'codegen/compiler'
require 'xxhash'

module StoutLang
  class Import
    def hash_file_xxhash(filename)
      return XXhash.xxh64_file(filename)
    end

    # Import types and functions from a compile bitcode module. Compile it first
    # if it's not already compiled
    def codegen(compile_jit, mod, func, bb, import_call)
      # Read the path from the first argument
      path = import_call.args[0].run

      cache_path = "builds/cache/#{path}"
      FileUtils.mkdir_p("builds/cache/#{File.dirname(path)}")

      # Hash the file to see if it's changed
      hash = hash_file_xxhash(path + ".sl") # TODO: this could be based off of the AST or something for more beefy speeds

      cache_path += "_#{hash}"

      if !File.exist?(cache_path+".bc")
        # Remove any previously cached files for this path
        Dir.glob("builds/cache/#{path}_*").each do |file|
          File.delete(file)
        end

        # Compile the file
        Compiler.compile(path + ".sl", cache_path, library=true, aot=true)
      end

      original_module = LLVM::Module.parse_bitcode(cache_path + ".bc")

      # compile_jit << original_module
      # Iterate over each function in the original module and create externs

      original_module.functions.each do |function|
        # TODO: The function pointers get overwritten when iterating (I think), so for now we don't use this
        # looked up function
        #
        # Don't re-import
        # TODO: janky
        next if mod.functions.named(function.name)

        function = original_module.functions.named(function.name)
        extern_function = mod.functions.add(
          function.name.dup,
          function.params.map(&:type).dup, # Map params to their types
          function.type.return_type.dup,
          # function.type.vararg? # Preserve var_arg status
        )
        # extern_function = nil

        # Add the function to the scope
        import_call.register_in_scope(function.name.clone + "", ExternFunc.new(extern_function))
      end


      # Don't link if we've already imported
      @@imports ||= {}
      if @@imports[path]
        return
      else
        @@imports[path] = true

        # Link the module into the root module
        original_module.link_into(mod)
      end

    end

  end
end