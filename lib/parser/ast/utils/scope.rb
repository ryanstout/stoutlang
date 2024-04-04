# Some AST nodes (File, Stuct, Fn's, Def's, Macro's, Callbacks) create a scope.
module StoutLang
  module Ast
    module Scope
      attr_accessor :parent

      def scope
        @scope ||= {}
        @scope
      end

      def register_identifier(identifier, node)
        name = self.name
        name = name.name if name.is_a?(StoutLang::Ast::Type)
        scope[identifier] = node
      end
    end
  end
end
