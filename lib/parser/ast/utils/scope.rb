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

        scope[identifier] ||= []
        # if scope[identifier].size > 0
        #   # TODO: temp until we migrate to full lookup
        #   raise "Duplicate identifier #{identifier} (#{node.inspect}) in #{name}"
        # end
        scope[identifier] << node
      end
    end
  end
end
