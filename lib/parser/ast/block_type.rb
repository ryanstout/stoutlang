require "parser/ast/callable_type"

module StoutLang
  module Ast
    class BlockType < CallableType
      def inspect_small
        "(#{arg_types.map(&:inspect_small).join(", ")})->#{return_type.inspect_small}"
      end
    end
  end
end
