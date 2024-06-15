require "codegen/compiler"
require "xxhash"
require "codegen/name_mangle"
require "codegen/constructs/construct"

module StoutLang
  class Import < Construct
    include NameMangle

    setup :args

    def hash_file_xxhash(filename)
      return XXhash.xxh64_file(filename)
    end

    def prepare(import_call)
      # Read the path from the first argument
      @path = import_call.args[0].run

      cache_path = "builds/cache/#{@path}"
      FileUtils.mkdir_p("builds/cache/#{File.dirname(@path)}")

      # Hash the file to see if it's changed
      hash = hash_file_xxhash(@path + ".sl") # TODO: this could be based off of the AST or something for more beefy speeds

      cache_path += "_#{hash}"

      if !File.exist?(cache_path + ".bc")
        # Remove any previously cached files for this path
        Dir.glob("builds/cache/#{@path}_*").each do |file|
          File.delete(file)
        end

        # Compile the file
        Compiler.compile(@path + ".sl", cache_path, { lib: true, aot: true })
      end

      @original_module = LLVM::Module.parse_bitcode(cache_path + ".bc")

      @imported_functions = []
      # Iterate over each function in the original module and create externs
      @original_module.functions.each do |function|
        func = self.unmangle(function.name)
        func_name = func[:func_name]
        args = func[:arg_types]
        return_type = func[:return_type]

        # extern_function.linkage = :private
        # extern_function = nil

        # Add the function to the scope
        if args
          # We have a stoutlang Def, not a C func

          raise "Return type not available when importing" if return_type.nil?
          prototype = DefPrototype.new(func_name, args, return_type)
          prototype.parent = self
          prototype.prepare
        else
          prototype = CPrototype.new(func_name, nil)
        end
        @imported_functions << [function, func_name, args, return_type, prototype]

        import_call.register_in_scope(func_name, prototype)
      end
    end

    # Import types and functions from a compile bitcode module. Compile it first
    # if it's not already compiled
    def codegen(compile_jit, mod, func, bb, import_call)
      @imported_functions.each do |function, func_name, args, return_type, prototype|
        function = @original_module.functions.named(function.name)

        # Don't import internal functions from the library we're importing
        # next if function.linkage == :private
        #

        # TODO: The function pointers get overwritten when iterating (I think), so for now we don't use this
        # looked up function
        #
        # Don't re-import
        # TODO: janky
        next if mod.functions.named(function.name)

        # Create a prototype for the function
        extern_function = mod.functions.add(
          function.name.dup,
          function.params.map(&:type).dup, # Map params to their types
          function.type.return_type.dup,
          # function.type.vararg? # Preserve var_arg status
        )
        func.linkage = :external

        prototype.ir = extern_function
      end

      # Don't link if we've already imported
      #  TODO: Expose imports somehow inside of stoutlang
      @@imports ||= {}
      if @@imports[@path]
        return
      else
        @@imports[@path] = true

        # Link the module into the root module
        @original_module.link_into(mod)
      end

      # Cleanup
      @original_module = nil
      @imported_functions = nil
    end
  end
end
