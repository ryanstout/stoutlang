module StoutLang
  module Ast
    class Macro < AstNode
      setup :name, :args, :block

      def prepare
        args.each(&:prepare)
        block.prepare
      end
    end
  end
end
