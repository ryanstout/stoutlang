require 'parser/ast/ast_node'

module StoutLang
  module Ast
    class InstanceVar < AstNode
      setup :name

      attr_accessor :ir

      def type
        Type.new("Int").assign_parent!(self)
      end

      def codegen_get_pointer(compile_jit, mod, func, bb)
        # Lookup self, should be a struct
        self_local = lookup_identifier('self')
        struct_type = self_local.type.resolve

        property_index = struct_type.properties.keys.index(name)

        if property_index.nil?
          raise("Instance variable #{name} not found on self")
        end

        # Get the property in the struct using gep
        property_pointer = bb.gep2(struct_type.ir, self_local.ir, [LLVM.Int(0), LLVM.Int(property_index)], "@#{name}")

        property_pointer
      end

      def codegen(compile_jit, mod, func, bb)
        # Lookup self, should be a struct
        property_pointer = codegen_get_pointer(compile_jit, mod, func, bb)

        # bb.store(LLVM::Int(32), property_pointer)

        bb.load2(LLVM::Int, property_pointer, name)
      end
    end
  end
end
