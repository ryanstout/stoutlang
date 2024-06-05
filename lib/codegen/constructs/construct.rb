# Base class for built-in functions.
# Constructs work like normal functions but are implemented at a lower level.

require 'parser/ast/utils/ast_scope'

module StoutLang
  class Construct
    include AstScope

    attr_accessor :parent

  end
end
