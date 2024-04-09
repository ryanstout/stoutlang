require 'parser/ast/utils/scope'

module StoutLang
  module Ast
    class Def < AstNode
      include Scope
      setup :name, :args, :block
      attr_accessor :ir

      def prepare
        super
        args.each do |arg|
          register_in_scope(arg.name.name, arg.type_sig)
        end
        block.prepare

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

      def codegen(mod, func, bb)
        func_types = args.map do |arg|
          arg.type_sig.codegen(mod, func, bb)
        end
        args = []
        return_type = LLVM::Type.void

        func = mod.functions.add(name, args, return_type) do |function|
          function.add_attribute :no_unwind_attribute

          bb, last_expr = block.codegen(mod, function, nil)

          bb.ret(last_expr)
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
