# StoutLang options for pass management
class PassManager
  def initialize(options)
    # Giving it no passes disables all passes
    @pass_builder = LLVM::PassBuilder.new

    @pass_builder.o!(options[:o]) if options[:o]
    if options[:o] == "3"
      @pass_builder.dce!
      @pass_builder.dse!
      @pass_builder.gdce!
      @pass_builder.adce!
      @pass_builder.bdce!
      @pass_builder.mem2reg!
      @pass_builder.strip!
      @pass_builder.strip_dead_prototypes!
    elsif options[:o] == "0"
      @pass_builder.dce!
      @pass_builder.globaldce!
      @pass_builder.adce!
    end
  end

  def run(mod, compile_jit)
    @pass_builder.run(mod, compile_jit.engine.target_machine)
  end
end
