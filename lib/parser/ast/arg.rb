# An argument to a function (in the Def, DefPrototype, etc..)

require 'parser/ast/utils/scope'
module StoutLang
  module Ast
    class Arg < AstNode
      setup :name, :type_sig
      attr_accessor :ir

      def type
        type_sig.type_val
      end

      def codegen(compile_jit, mod, func, bb)
        self.ir
      end

      def to_h
        {name: name, type: type_sig.to_h}
      end
    end
  end
end
