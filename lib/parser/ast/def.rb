require "parser/ast/callable"
require "parser/ast/utils/scope"
require "codegen/metadata"
require "base64"
require "codegen/name_mangle"

module StoutLang
  module Ast
    class Def < Callable
      def type
        # The type of a block is a BlockType, which should match the BlockType
        # on the function being called
        args = self.args.map { |arg| arg.resolve.type }
        return_type = self.return_type

        return DefType.new(args, return_type).assign_parent!(self)
      end

      def prepare
        super

        # Def's created inside of a struct should register themselves in the parent struct.
        scope = parent_scope
        if scope.is_a?(StoutLang::Ast::Struct) && scope.name.name != "Root"
          # Move up one more so the internal struct functions are avaible from the parent
          scope = scope.parent_scope
        end
        scope.register_identifier(name, self)
      end

      def effects
        exps.effects
      end

      def codegen(compile_jit, mod, func, bb)
        super
      end

      def inspect_small
        arg_types = args.map { |arg| arg.type_sig.type_val.inspect_small }
        "#{name}(#{arg_types.join(", ")}) -> #{return_type.inspect_small}"
      end
    end
  end
end
