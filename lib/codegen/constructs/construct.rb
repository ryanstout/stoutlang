# Base class for built-in functions.
# Constructs work like normal functions but are implemented at a lower level.

require 'parser/ast/utils/ast_scope'

module StoutLang
  class Construct < StoutLang::Ast::AstNode

    def prepare(*args)
      # noop, override
    end
  end
end
