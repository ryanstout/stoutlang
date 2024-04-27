# StoutLang options for pass management
class PassManager
  def initialize
    # Giving it no passes disables all passes
    @pass_manager = LLVM::PassManager.new

    # passes = LLVM::PassBuilder.new.methods.grep(/\S!$/)
    # except_passes = [
    #   :adce!, :dce!, :bdce!, :alignment_from_assumptions!, :simplifycfg!, :dse!,
    #   :scalarizer!, :mldst_motion!, :gvn!, :newgvn!, :indvars!, :instcombine!,
    #   :instsimplify!, :jump_threading!, :licm!, :loop_deletion!, :loop_idiom!,
    #   :loop_rotate!, :loop_reroll!, :loop_unroll!, :loop_unroll_and_jam!,
    #   :loop_unswitch!, :loweratomic!, :memcpyopt!, :partially_inline_libcalls!,
    #   :reassociate!, :sccp!, :scalarrepl!, :scalarrepl_ssa!, :scalarrepl_threshold!,
    #   :simplify_libcalls!, :tailcallelim!, :constprop!, :reg2mem!, :verify!,
    #   :cvprop!, :early_cse!, :early_cse_memssa!, :lower_expect!,
    #   :lower_constant_intrinsics!, :tbaa!, :scoped_noalias_aa!, :basicaa!,
    #   :mergereturn!, :lowerswitch!, :mem2reg!
    # ].freeze
    # passes = passes - except_passes
    # passes.each do |pass|
    #   begin
    #     @pass_manager.public_send(pass)
    #   rescue LLVM::DeprecationError => e
    #     # ignore
    #   rescue NoMethodError => e
    #     # also ignore
    #   end
    # end
  end

  def run(mod)
    @pass_manager.run(mod)
  end
end
