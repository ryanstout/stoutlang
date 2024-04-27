require 'codegen/constructs/construct'

module StoutLang
  class Return < Construct
    def codegen(compile_jit, mod, func, bb, return_call)
      if return_call.args.empty?
        bb.ret_void
      else
        # TODO: Multiple arg returns
        bb.ret(return_call.args.first.codegen(compile_jit, mod, func, bb))
      end
    end
  end
end
