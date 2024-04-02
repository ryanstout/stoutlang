require 'parser/ast/utils/scope'

module StoutLang
  module Ast
    class Def < AstNode
      include Scope
      setup :name, :args, :block

      def prepare
        args.each(&:prepare)
        block.prepare
      end
    end

    class DefArg < AstNode
      setup :name, :type_sig
    end
  end
end
