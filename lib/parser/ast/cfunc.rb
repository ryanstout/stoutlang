require 'parser/ast/def'

module StoutLang
  module Ast
    class CFunc < Def
       # doesn't take a block like Def does
      setup :name, :args, :return_type

    end
  end
end
