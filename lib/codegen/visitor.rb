require 'llvm'
require 'llvm/core'
require 'llvm/execution_engine'
require 'dibuilder/dibuilder'
require 'benchmark'
require 'pry'
require 'llvm/linker'
require 'codegen/mcjit'
require 'codegen/llvm/module'
require 'parser/parser'

def bm(name)
  start_time = Time.now
  yield
  end_time = Time.now

  execution_time = end_time - start_time
  puts "#{name}: #{execution_time} seconds"
end

class Visitor
  attr_reader :mod, :main

  def initialize(ast, file_path=nil, library=false)
    @library = library

    # Init Jit for compiler's jit
    @root_mod = LLVM::Module.new('root')

    setup_compile_jit(@root_mod)

    # @context = LLVM::Context.new

    @ast = ast
    @ast.prepare


    # Make a dibuilder
    @dibuilder = DIBuilder.new(@root_mod)
    if file_path.nil?
      file_path = "unknown.sl"
    end
    @dibuilder.create_compile_unit(file_path)

    # Register the build in types
    @ast.register_identifier("Int", StoutLang::Int)
    @ast.register_identifier("Str", StoutLang::Str)
    @ast.register_identifier("Bool", StoutLang::Bool)
    @ast.register_identifier('import', StoutLang::Import)


    # main_mod = LLVM::Module.new('main_mod')
    if library
      @ast.codegen(@compile_jit, @root_mod, nil, nil)
    else
      @main = @root_mod.functions.add('main', [], LLVM::Int32) do |function|
        function.basic_blocks.append('entry').build do |b|
          # Codegen in place in the main ast
          @ast.codegen(@compile_jit, @root_mod, function, b)

          zero = LLVM.Int(0) # a LLVM Constant value
          b.ret zero
        end
      end

      puts "RUN main"
      @compile_jit.run_function(@main)
      puts "RAN main"
    end


    # Link the other modules added to the jit to root_mod
    # @compile_jit.modules.reject {|mod| mod == @root_mod }.each do |mod|
    #   # I'm not sure why we have to link these backwards?, segfault otherwise
    #   failed, error = @root_mod.link_into(mod)
    #   if failed
    #     raise "Link Error: #{error}"
    #   end
    #   @root_mod = mod
    # end

    puts "----------------"
    @root_mod.dump
    @root_mod.verify

  end

  def setup_compile_jit(main_mod)
    @compile_jit = MCJit.new(main_mod, 0)
  end

  def generate(output_file_path, aot=false, wasm=false)


    # return
    unless aot

      return

      # engine = LLVM::MCJITCompiler.new(@root_mod)
      # engine.run_function(@main)
      # engine.dispose
    else

      # Get the current machine's triple
      # triple = LLVM::C.get_default_target_triple


      bm('write llir') do
        @root_mod.write_ir!("#{output_file_path}.ll")
        @root_mod.write_bitcode("#{output_file_path}.bc")
      end

      if wasm
        system("llc -march=wasm32  #{output_file_path}.ll -o #{output_file_path}.wat")
        system("wat2wasm #{output_file_path}.wat -o #{output_file_path}.wasm")
      end

      opt_level = ' -flto'
      # opt_level = ' -03 '

      # Compile LLVM IR to machine code
      bm('llc') do
        system("llc #{output_file_path}.bc -o #{output_file_path}.s")
      end

      if @library
        # Build an object
        bm('clang') do
          system("clang -c #{output_file_path}.s #{opt_level} -o #{output_file_path}.o")
        end
      else
        # Link machine code to create an executable
        bm('clang') do
          #  -nostdlib (enable once we get musl)
          system("clang #{output_file_path}.s #{opt_level} -o #{output_file_path}")
        end
      end
    end
  end
end
