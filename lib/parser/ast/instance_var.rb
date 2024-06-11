# Instace variables get resolved to from Identifiers.
# (So Identifiers are what the AST parses, but any Identifier that starts with an '@' is resolved to an InstanceVar)
# The InstanceVar is parented to the Identifier.

require 'parser/ast/ast_node'

module StoutLang
  module Ast
    class InstanceVar < AstNode
      setup :name

      attr_accessor :ir

      def get_self_struct_and_index
        # Lookup self, should be a struct
        self_local = lookup_identifier('@')

        # Resolve to the Struct type (not Type.new, but {StructName}.new)
        struct_type = self_local.type.resolve

        property_index = struct_type.properties_hash.keys.index(name[1..-1])

        if property_index.nil?
          raise("Instance variable #{name} not found on self")
        end

        return self_local, struct_type, property_index
      end

      # The type of the instance variable type. We have to look it up on the struct to
      # get it.
      def type
        self_local, struct_type, property_index = get_self_struct_and_index

        property_type = struct_type.properties_hash.values[property_index]

        property_type.assign_parent!(self)
      end

      def codegen_get_pointer(compile_jit, mod, func, bb)
        self_local, struct_type, property_index = get_self_struct_and_index

        # Get the property in the struct using gep
        return bb.gep2(struct_type.ir, self_local.ir, [LLVM.Int(0), LLVM.Int(property_index)], name)
      end

      def codegen(compile_jit, mod, func, bb)
        # Lookup self, should be a struct
        property_pointer = codegen_get_pointer(compile_jit, mod, func, bb)

        bb.load2(LLVM::Int, property_pointer, name)
      end
    end
  end
end
