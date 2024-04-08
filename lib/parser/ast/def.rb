require 'parser/ast/utils/scope'

module StoutLang
  module Ast
    class Def < AstNode
      include Scope
      setup :name, :args, :block

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

      def codegen(mod, bb)
        func_types = args.map do |arg|
          arg.type_sig.codegen(mod, bb)
        end
        func = mod.functions.add(name, )

        func_body = block.codegen(mod, bb)

        block = LLVM::BasicBlock.create(mod, "entry", function_body)
      end
    end

    class DefArg < AstNode
      setup :name, :type_sig
    end
  end
end
