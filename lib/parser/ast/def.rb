require 'parser/ast/utils/scope'

module StoutLang
  module Ast
    class Def < AstNode
      include Scope
      setup :name, :args, :return_type, :block
      attr_accessor :ir

      def prepare
        super
        args.each do |arg|
          register_in_scope(arg.name.name, arg.type_sig)
        end
        block.prepare

        # Def's should register themselves in the parent scope
        parent_scope.register_identifier(name, self)
      end

      def effects
        block.expressions.map do |exp|
          exp.effects
        end.flatten.uniq
      end

      def run
        # for dev, we don't run it when we define it, only when we call it
      end

      def codegen(compile_jit, mod, func, bb)
        func_args = args.map do |arg|
          arg.type_sig.codegen(compile_jit, mod, func, bb)
        end

        return_type_ir = return_type.codegen(compile_jit, mod, func, bb)

        last_expr = nil
        func = mod.functions.add(name, func_args, return_type_ir) do |function|
          function.add_attribute :no_unwind_attribute
          function.linkage = :external

          args.each_with_index do |arg, i|
            # Register the argument in the scope
            register_in_scope(arg.name.name, function.params[i])
          end

          # Create a block to do the codegen inside of
          function.basic_blocks.append('entry').build do |bb|
            last_expr = block.codegen(compile_jit, mod, function, bb)

            # Return the value of the last expression
            bb.ret(last_expr)
          end
        end

        self.ir = func


        return func
      end
    end

    class DefArg < AstNode
      setup :name, :type_sig
    end
  end
end
