require "parser/ast/utils/scope"
require "codegen/visitor"

module StoutLang
  module Ast
    class Struct < AstNode
      include Scope
      setup :name, :body
      attr_accessor :ir
      attr_reader :properties_hash

      SIZE_METHOD_NAME = "i32_size"

      def add_expression(expression)
        body.add_expression(expression)
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
        # Create an arg for each property in the body
        args = []
        body.expressions.each do |exp|
          if exp.is_a?(Property)
            arg = Arg.new(exp.name, exp.type_sig)
            arg.parent = exp.parent

            args << arg
          end
        end

        args
      end

      def build_properties_hash
        @properties_hash = {}
        body.expressions.each do |exp|
          if exp.is_a?(Property)
            @properties_hash[exp.name.name] = exp.type_sig.type_val
          end
        end
      end

      # We create a default constructor, which may be overridden later.
      def create_new_constructor
        # Create a default new constructor and insert it into the top of the AST for the Struct
        args_str = ["@: #{name.name}"]
        assignments = []

        properties_hash.each do |name, type|
          args_str << "#{name}: #{type.name}"
          assignments << "@#{name} = #{name}"
        end

        code = <<-END
          def new(#{args_str.join(", ")}) -> #{name.name} {
            #{assignments.join("\n")}
            return @
          }
        END

        new_constructor = Parser.new.parse(code, wrap_root: false)
        new_constructor_def = new_constructor.expressions[0]
        make_children!(new_constructor_def)
        body.expressions.unshift(new_constructor_def)
      end

      def prepare
        build_properties_hash

        # Add the struct to the parent scope
        if parent_scope
          parent_scope.register_identifier(name.name, self)
        elsif name.name != "Root" # TODO, this should check for the specific Root instance, not just the name root
          raise "No parent scope for #{name.name}"
        end

        if name.name != "Root"
          # Create a method to look up the size of the struct (.i32_size)
          extern = DefPrototype.new(SIZE_METHOD_NAME, [Arg.new("@", TypeSig.new(Type.new(name.name)))], Type.new("Int"))
          make_children!(extern)
          parent_scope.register_identifier(SIZE_METHOD_NAME, extern)
          extern.prepare

          create_new_constructor
        end

        body.prepare
      end

      def run
        body.run
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

        body.expressions.map do |exp|
          if exp.is_a?(Property)
            type_llvm_value = exp.type_sig.codegen(compile_jit, mod, func, bb)
            types << type_llvm_value
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
          size_method.linkage = :link_once_odr
        end

        # Build the IR for the body
        ir = body.codegen(compile_jit, mod, func, bb)

        return ir
      end
    end
  end
end
