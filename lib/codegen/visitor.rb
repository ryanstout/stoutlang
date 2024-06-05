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
require 'codegen/name_mangle'
require 'codegen/llvm/llvm_string'
require 'codegen/pass_manager'

def bm(name)
  start_time = Time.now
  yield
  end_time = Time.now

  execution_time = end_time - start_time
  # puts "#{name}: #{execution_time} seconds"
end

class Visitor
  attr_reader :root_mod, :main

  def initialize(ast, file_path=nil, options={})
    @options = options

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

    # TODO: Not adding debug info atm because of version warning
    # @dibuilder.create_compile_unit(file_path)
    # @dibuilder.finalize


    # Automatically import core/core
    if file_path !~ /^core\//
      add_core_import(ast)
    end

    if options[:lib]
      @ast.codegen(@compile_jit, @root_mod, nil, nil)
    else
      @main = @root_mod.functions.add('main', [], LLVM::Int32) do |function|
        function.basic_blocks.append('entry').build do |b|
          # Codegen in place in the main ast
          @ast.codegen(@compile_jit, @root_mod, function, b)

          # Check if main already has a return
          # TODO: This check won't handle early returns with an unreachable block after
          last_instruction = function.basic_blocks.last.instructions.last
          if !last_instruction || last_instruction.opcode != :ret
            zero = LLVM.Int(0) # a LLVM Constant value
            b.ret zero
          end

        end
      end

      PassManager.new(options).run(@root_mod, @compile_jit)


      if options[:ir]
        puts "----------------"
        puts "LLVM IR:"
        @root_mod.dump
        puts "----------------"
      end

      @root_mod.verify
      # puts "----------------"

      # PassManager.new.run(@root_mod)

      @compile_jit.run_function(@main)
    end
  end

  def run
    ret_val = @compile_jit.run_function(@main)

    return ret_val.to_i
  end

  def run_function(name, arg_types, return_type, *call_args)
    mangled_name = NameMangle.mangle_name(name, arg_types, return_type)
    func = @root_mod.functions.named(mangled_name)

    raise "Unable to find function #{mangled_name}" if func.nil?
    mcjit_result = @compile_jit.run_function(func, *call_args)

    return mcjit_result
  end

  def setup_compile_jit(main_mod)
    @compile_jit = MCJit.new(main_mod, 0)
  end

  def dispose
    # @compile_jit.dispose
    # GC.start
  end

  def generate(output_file_path, wasm=false)


    # return
    if !@options[:aot]

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
      # opt_level = ' -03 -flto'

      # Compile LLVM IR to machine code
      bm('llc') do
        system("llc #{output_file_path}.bc -o #{output_file_path}.s")
      end

      if @options[:lib]
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

  def add_core_import(ast)
    import_func_call = FunctionCall.new(
      'import',
      [StringLiteral.new(['core/core'])],
    )
    import_func_call.parent = ast

    @ast.block.expressions.unshift(
      import_func_call
    )
  end
end
