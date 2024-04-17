require 'llvm'
require 'llvm/core'


class MCJit
  attr_reader :engine
  def initialize
    LLVM.init_jit(true)
    main_mod = LLVM::Module.new('main')
    @engine = LLVM::MCJITCompiler.new(main_mod, :opt_level => 0)
  end

  def add_module(module_ptr)
    @engine.modules << module_ptr
  end

  def run_function(function, *args)
    @engine.run_function(function, *args)
  end
end
