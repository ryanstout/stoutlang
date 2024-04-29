# StoutLang options for pass management
class PassManager
  def initialize(options)
    # Giving it no passes disables all passes
    @pass_builder = LLVM::PassBuilder.new

    @pass_builder.o!(options[:o]) if options[:o]
    @pass_builder.gdce! if options[:o] == '3'
    @pass_builder.adce! if options[:o] == '3'
  end

  def run(mod, compile_jit)
    @pass_builder.run(mod, compile_jit.engine.target_machine)
  end
end
