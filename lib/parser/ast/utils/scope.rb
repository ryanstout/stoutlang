# Some AST nodes (File, Stuct, Fn's, Def's, Macro's, Callbacks) create a scope.
module StoutLang
  module Ast
    module Scope
      def prepare
        @scope = {}
        super
      end

      def register_in_scope(identifier, node)
        @scope[identifier] = node
      end

    end
  end
end
