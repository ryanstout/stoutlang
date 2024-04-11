require 'parser/ast/utils/scope'
require 'codegen/visitor'

module StoutLang
  module Ast
    class Struct < AstNode
      include Scope
      setup :name, :block
      attr_accessor :ir

      def add_expression(expression)
        block.add_expression(expression)
      end

      def prepare
        # Add the struct to the parent scope
        if parent_scope
          parent_scope.register_identifier(name, self)
        end

        block.prepare
      end

      def run
        block.run
      end

      def codegen(mod, func, bb)
        # Create the LLVM::Type in LLVM

        # Create the i32 tag
        tag = LLVM::Int32Ty

        # Get the list of types from each property on the struct
        types = []

        block.expressions.map do |exp|
          if exp.is_a?(Property)
            types << exp.type_sig.codegen(mod, func, bb)
          end
        end

        # Create the data type
        data = LLVM::Type.struct(types, false)

        struct_type = LLVM::Type.struct([tag, data], false, name.name)

        # Add the struct to the identifier table
        self.ir = struct_type

        # Build the IR for the block
        block.codegen(mod, func, bb)
      end
    end
  end
end
