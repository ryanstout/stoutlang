require 'llvm'
require 'llvm/core'
require 'llvm/execution_engine'
require 'dibuilder/dibuilder'
require 'benchmark'
require 'pry'
require 'llvm/linker'
require 'codegen/mcjit'
require 'codegen/llvm/module'

def bm(name)
  start_time = Time.now
  yield
  end_time = Time.now

  execution_time = end_time - start_time
  puts "#{name}: #{execution_time} seconds"
end

class Visitor
  attr_reader :mod, :main

  def initialize(ast, file_path=nil)
    # Init Jit for compiler's jit
    LLVM.init_jit
    setup_compile_jit

    # @context = LLVM::Context.new

    @ast = ast
    @ast.prepare

    @root_mod = LLVM::Module.new('root')#, @context)

    # Make a dibuilder
    @dibuilder = DIBuilder.new(@root_mod)
    if file_path.nil?
      file_path = "unknown.sl"
    end
    @dibuilder.create_compile_unit(file_path)

    print_mod = LLVM::Module.new('print_mod')#, @context)
    cputs = print_mod.functions.add('puts', [LLVM.Pointer(LLVM::Int8)], LLVM::Int32) do |function, string|
      function.add_attribute :no_unwind_attribute
      string.add_attribute :no_capture_attribute
    end

    # Register the build in types
    @ast.register_identifier("Int", StoutLang::Int)
    @ast.register_identifier("Str", StoutLang::Str)
    @ast.register_identifier("Bool", StoutLang::Bool)

    # Register cputs as %> on root
    cputs_func = ExternFunc.new(cputs)
    @ast.register_identifier('%>', cputs_func)

    @compile_jit << print_mod

    # main_mod = LLVM::Module.new('main_mod')
    @main = @root_mod.functions.add('main', [], LLVM::Int32) do |function|
      function.basic_blocks.append('entry').build do |b|

        # Codegen in place in the main ast
        @ast.codegen(@compile_jit, @root_mod, function, b)

        zero = LLVM.Int(0) # a LLVM Constant value
        b.ret zero
      end
    end

    @compile_jit << @root_mod

    @compile_jit.run_function(@main)

    # Link the other modules added to the jit to root_mod
    @compile_jit.modules.reject {|mod| mod == @root_mod }.each do |mod|
      # I'm not sure why we have to link these backwards?, segfault otherwise
      failed, error = @root_mod.link_into(mod)
      if failed
        raise "Link Error: #{error}"
      end
      @root_mod = mod
    end

    @root_mod.dump
    @root_mod.verify

  end

  def setup_compile_jit
    @compile_jit = MCJit.new(0)
  end

  def generate(output_file_path, aot=false)


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
        @root_mod.write_ir!("#{output_file_path}.bc")
        @root_mod.write_bitcode("#{output_file_path}.ll")
      end

      opt_level = ''
      # opt_level = ' -03 '

      # Compile LLVM IR to machine code
      bm('llc') do
        system("llc #{opt_level} #{output_file_path}.ll -o #{output_file_path}.s")
      end

      # Link machine code to create an executable
      bm('clang') do
        #  -nostdlib (enable once we get musl)
        system("clang #{opt_level} -flto #{output_file_path}.s -o #{output_file_path}")
      end
    end
  end
end
