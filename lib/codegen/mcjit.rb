require 'llvm'
require 'llvm/core'


class MCJit
  attr_reader :engine, :modules
  def initialize(opt_level=0)
    LLVM.init_jit(true)
    main_mod = LLVM::Module.new('__empty__')
    @engine = LLVM::MCJITCompiler.new(main_mod, :opt_level => opt_level)
    @modules = []
  end

  def <<(module_ptr)
    # You can't do .each on engine.modules, so keep a 2nd list
    @modules << module_ptr

    @engine.modules << module_ptr
  end

  def run_function(function, *args)
    @engine.run_function(function, *args)
  end
end
