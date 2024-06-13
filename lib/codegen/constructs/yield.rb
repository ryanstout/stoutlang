require 'codegen/constructs/construct'

module StoutLang
  class Yield < Construct
    setup :args
    # def prepare(func_call)
    #   puts "PREPARE CALLED ON YIELD"
    #   @func_call = func_call
    # end

    def return_type
      # Look up the block argument
      block_arg = parent_scope.lookup_identifier('block')

      unless block_arg
        raise "return_type called, but no block provided"
      end

      block_arg.return_type
    end

    def type
      # Look up the block argument

      block_arg = parent_scope.lookup_identifier('block')

      unless block_arg
        raise "type called, but no block provided"
      end

      block_arg.type
    end

    def codegen(compile_jit, mod, func, bb, yield_call)
      # Look up the block argument, call with the args passed to yield

      block_arg = parent_scope.lookup_identifier('block')

      unless block_arg
          raise "Yield called, but no block provided"
      end


      arg = block_arg.codegen(compile_jit, mod, func, bb)

      block_type_ir = block_arg.type_sig.type_val.type_ir_codegen(compile_jit, mod, func, bb)

      args_ir = yield_call.args.map { |arg| arg.codegen(compile_jit, mod, func, bb) }

      bb.call2(block_type_ir, arg, *args_ir)
    end
  end
end
