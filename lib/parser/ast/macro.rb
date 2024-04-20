# Macro's and Def's are essentially the same except macro's are evaluated at compile time.
require 'parser/ast/def'

module StoutLang
  module Ast
    class Macro < Def
    end
  end
end
