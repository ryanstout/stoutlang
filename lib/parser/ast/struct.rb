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

      def codegen(compile_jit, mod, func, bb)
        # Create the LLVM::Type in LLVM

        # Unions
        # # Create the i32 tag
        # tag = LLVM::Int32Ty

        # # Get the list of types from each property on the struct
        types = []

        block.expressions.map do |exp|
          if exp.is_a?(Property)
            type = exp.type_sig.codegen(compile_jit, mod, func, bb)
            types << type
          end
        end

        # # Create the data type
        # data = LLVM::Type.struct(types, false)

        # struct_type = LLVM::Type.struct([tag, data], false, name.name)

        # # Add the struct to the identifier table
        # self.ir = struct_type

        struct = LLVM::Type.struct(types, false, name.name)

        self.ir = struct

        # Register the struct in its parent scope
        if parent_scope
          parent_scope.register_identifier(name.name, self)

          # Define a size method that returns the size of LLVM::Int
          size_method = mod.functions.add("i32_size", [], LLVM::Int64) do |function|
            function.basic_blocks.append("entry").build do |builder|
              builder.ret struct.size
            end
          end

          parent_scope.register_identifier("i32_size", size_method)
        end

        # Create a new function, which mallocs the struct, then calls the init function



        # Build the IR for the block
        block.codegen(compile_jit, mod, func, bb)
      end
    end
  end
end
