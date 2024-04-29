require 'parser/ast/utils/scope'
require 'codegen/visitor'
require 'codegen/expressions/struct_constructor'

module StoutLang
  module Ast
    class Struct < AstNode
      include Scope
      setup :name, :block
      attr_accessor :ir

      SIZE_METHOD_NAME = "i32_size"


      def add_expression(expression)
        block.add_expression(expression)
      end

      def constructor_args
        # Create an arg for each property in the block
        args = []
        block.expressions.each do |exp|
          if exp.is_a?(Property)
            arg = Arg.new(exp.name, exp.type_sig)
            arg.parent = exp.parent

            args << arg
          end
        end

        args
      end

      def register_constructors
        return
        # Loop through the block and find all of the init functions
        block.expressions.each do |exp|
          if exp.is_a?(Def) && exp.name == "init"
            # Create a constructor function for the struct
            constructor = StructConstructor.new(self.ir, constructor_args)
            parent_scope.register_identifier(name.name, constructor)
          end
        end
      end

      def prepare
        # Add the struct to the parent scope
        if parent_scope
          parent_scope.register_identifier(name.name, self)
        end


        extern = DefPrototype.new(SIZE_METHOD_NAME, [], Type.new("Int"))
        register_identifier(SIZE_METHOD_NAME, extern)
        extern.prepare

        block.prepare

        # Find all of the init functions and make an associated constructor function
        register_constructors
      end

      def run
        block.run
      end

      # The size of the struct in bytes
      def bytesize(compile_jit)
        raise "Struct codegen has not been run" unless self.ir

        # TODO: Seems like there should be a better way to calculate this
        target_data = compile_jit.engine.data_layout

        # Get the size of the struct using target data
        size_val = target_data.bit_size_of(self.ir).to_i

        return size_val / 8
      end

      def codegen(compile_jit, mod, func, bb)
        # After the first codegen, we just want a reference to the struct type
        if self.ir
          # pointer = bb.alloca(self.ir)

          # call_func = mod.functions["sl1.init(Point,Int,Int)->Point"]
          # call = bb.call(call_func, [pointer])

          # return pointer
          return self.ir.pointer
        end


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

        # Save the struct ir reference, this allows us to call .codegen on the struct to get the reference
        self.ir = struct

        # TODO: This probably isn't needed
        # mod.globals.add(struct, name.name)

        # Register the struct's methods in its parent scope
        if parent_scope
          # Define a size method that returns the size of LLVM::Int
          size_method = mod.functions.add("sl1.#{SIZE_METHOD_NAME}()->Int", [], LLVM::Int32) do |function|
            function.basic_blocks.append("entry").build do |builder|
              size_const = LLVM::Int(self.bytesize(compile_jit))

              builder.ret size_const
            end
          end
        end

        # Create a new function, which mallocs the struct, then calls the init function



        # Build the IR for the block
        block.codegen(compile_jit, mod, func, bb, true)
      end
    end
  end
end
