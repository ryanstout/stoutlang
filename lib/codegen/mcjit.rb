require "llvm"
require "llvm/core"
require "llvm/lljit"

class MCJit
  attr_reader :engine, :modules

  def initialize(main_mod, opt_level = 0)
    LLVM.init_jit(true)

    # @engine = LLVM::LLJit.new#(main_mod, :opt_level => opt_level)
    @engine = LLVM::MCJITCompiler.new(main_mod, :opt_level => opt_level)
    @modules = []
  end

  def <<(module_ptr)
    # raise "Not implemented"
    # # You can't do .each on engine.modules, so keep a 2nd list
    @modules << module_ptr

    @engine.modules << module_ptr
  end

  def run_function(function, *args)
    @engine.run_function(function, *args)
  end

  def dispose
    @modules.each do |mod|
      @engine.remove_module(mod)
    end

    @engine.dispose
  end
end
