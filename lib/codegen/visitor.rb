require 'llvm'
require 'llvm/core'
require 'llvm/execution_engine'
require 'dibuilder/dibuilder'
require 'benchmark'

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
    @ast = ast
    @ast.prepare

    @mod = LLVM::Module.new('root')
    @builder = LLVM::Builder.new

    # Make a dibuilder
    @dibuilder = DIBuilder.new(@mod)
    if file_path.nil?
      file_path = "unknown.sl"
    end
    @dibuilder.create_compile_unit(file_path)

    cputs = @mod.functions.add('puts', [LLVM.Pointer(LLVM::Int8)], LLVM::Int32) do |function, string|
      function.add_attribute :no_unwind_attribute
      string.add_attribute :no_capture_attribute
    end

    # Register the build in types
    @ast.register_identifier("Int", StoutLang::Int)
    @ast.register_identifier("Str", StoutLang::Str)

    # Register cputs as %> on root
    cputs_func = ExternFunc.new(cputs)
    @ast.register_identifier('%>', cputs_func)

    @main = @mod.functions.add('main', [], LLVM::Int32) do |function|
      function.basic_blocks.append.build do |b|

        # Codegen in place in the main ast
        @ast.codegen(@mod, function, b)

        zero = LLVM.Int(0) # a LLVM Constant value
        b.ret zero
      end
    end

  end

  def generate(output_file_path, aot=false)

    @mod.dump
    @mod.verify

    puts "-------------"

    unless aot
      # Run JITted
      LLVM.init_jit

      engine = LLVM::MCJITCompiler.new(@mod)
      engine.run_function(@main)
      engine.dispose
    else

      # Get the current machine's triple
      # triple = LLVM::C.get_default_target_triple

      bm('write llir') do
        @mod.write_ir!("#{output_file_path}.bc")
        @mod.write_bitcode("#{output_file_path}.ll")
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
