require 'parser/ast/utils/scope'

module StoutLang
  module Ast
    class Struct < AstNode
    include Scope
      setup :name, :block
    end
  end
end
