require 'parser/ast/utils/scope'
require 'codegen/visitor'


module StoutLang
  module Ast
    class Struct < AstNode
      include Scope
      setup :name, :block
      attr_accessor :ir
      attr_reader :properties

      SIZE_METHOD_NAME = "i32_size"


      def add_expression(expression)
        block.add_expression(expression)
      end

      def resolve
        self
      end

      # The struct type's name doesn't mangle for now, but it has a caps.
      # This gets called when generating def names
      def mangled_name
        name
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

      def prepare
        # Add the struct to the parent scope
        if parent_scope
          parent_scope.register_identifier(name.name, self)
        elsif name.name != "Root" # TODO, this should check for the specific Root instance, not just the name root
          raise "No parent scope for #{name.name}"
        end

        if name.name != "Root"
          # Create a method to look up the size of the struct (.i32_size)
          extern = DefPrototype.new(SIZE_METHOD_NAME, [Arg.new('self', TypeSig.new(Type.new(name.name)))], Type.new("Int"))
          make_children!(extern)
          parent_scope.register_identifier(SIZE_METHOD_NAME, extern)
          extern.prepare
        end

        block.prepare
      end

      def run
        block.run
      end

      def type
        Type.new(name.name).assign_parent!(self)
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
        @properties = {} # an ordered hash

        block.expressions.map do |exp|
          if exp.is_a?(Property)
            type = exp.type_sig.codegen(compile_jit, mod, func, bb)
            types << type
            @properties[exp.name.name] = type
          end
        end

        # # Create the data type
        struct = LLVM::Type.struct(types, false, name.name)

        # Save the struct ir reference, this allows us to call .codegen on the struct to get the reference
        self.ir = struct

        # TODO: This probably isn't needed
        # mod.globals.add(struct, name.name)

        # Register the struct's methods in its parent scope
        struct_size_const = LLVM::Int(self.bytesize(compile_jit))

        if parent_scope
          # Define a size method that returns the size of LLVM::Int32
          size_method = mod.functions.add("sl1.#{SIZE_METHOD_NAME}(#{name.name})->Int", [], LLVM::Int32) do |function|
            function.basic_blocks.append("entry").build do |builder|
              builder.ret struct_size_const
            end
          end
        end

        # Build the IR for the block
        ir = block.codegen(compile_jit, mod, func, bb, true)

        return ir
      end
    end
  end
end
