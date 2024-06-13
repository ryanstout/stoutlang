require 'parser/ast/callable_type'
module StoutLang
  module Ast
    class BlockType < CallableType
      def mangled_name
        "sl1.block_#{self.arg_types.map(&:mangled_name).join('_')}_#{return_type.mangled_name}_type"
      end
    end
  end
end
