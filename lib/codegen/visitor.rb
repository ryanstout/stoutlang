require 'llvm/core'
require 'llvm/execution_engine'
require 'benchmark'

def bm(name)
  start_time = Time.now
  yield
  end_time = Time.now

  execution_time = end_time - start_time
  puts "#{name}: #{execution_time} seconds"
end

class Visitor
  def initialize(ast, output_file_path, aot=false)
    @ast = ast
    @ast.prepare

    @mod = LLVM::Module.new('root')
    @builder = LLVM::Builder.new

    puts "Parse: #{ast.inspect}"

    cputs = @mod.functions.add('puts', [LLVM.Pointer(LLVM::Int8)], LLVM::Int32) do |function, string|
      function.add_attribute :no_unwind_attribute
      string.add_attribute :no_capture_attribute
    end

    # Register cputs as => on root
    @ast.register_identifier('=>', cputs)


    main = @mod.functions.add('main', [], LLVM::Int32) do |function|
      function.basic_blocks.append.build do |b|
        # Codegen in place the main ast
        @ast.codegen(@mod, b)

        zero = LLVM.Int(0) # a LLVM Constant value
        b.ret zero
      end
    end

    @mod.dump
    @mod.verify

    puts "-------------"

    unless aot
      # Run JITted
      LLVM.init_jit

      engine = LLVM::JITCompiler.new(@mod)
      engine.run_function(main)
      engine.dispose
    else

      # Get the current machine's triple
      # triple = LLVM::C.get_default_target_triple

      bm('write llir') do
        @mod.write_bitcode("builds/out.ll")
      end

      # Compile LLVM IR to machine code
      bm('llc') do
        system("llc -O3 builds/out.ll -o builds/out.s")
      end

      # Link machine code to create an executable
      bm('clang') do
        #  -nostdlib (enable once we get musl)
        system("clang -O3 -flto builds/out.s -o builds/out")
      end
    end
  end
end
