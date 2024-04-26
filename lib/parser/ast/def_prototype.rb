# A def prototype represents a def we imported from another file. It only codegens the prototype.

require 'parser/ast/utils/scope'
require 'parser/ast/def'

module StoutLang
  module Ast
    class DefPrototype < Def
      setup :name, :args, :return_type # no block

      def prepare

      end

      def effects
        raise "Not implemented"
      end

      # For now we don't need to codegen, when created, we set the ir to the function we found when
      # importing the file (see import.rb)
      # def codegen(compile_jit, mod, func, bb)
      #   func_args = args.map do |arg|
      #     arg.type_sig.codegen(compile_jit, mod, func, bb)
      #   end

      #   if return_type.nil?
      #     raise "Return types are required right now"
      #   end
      #   return_type_ir = return_type.codegen(compile_jit, mod, func, bb)

      #   func = mod.functions.add(mangled_name, func_args, return_type_ir) do |function|
      #     function.add_attribute :no_unwind_attribute
      #     function.linkage = :internal
      #   end

      #   self.ir = func

      #   return func
      # end
    end
  end
end
