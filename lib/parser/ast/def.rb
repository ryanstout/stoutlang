require 'parser/ast/utils/scope'
require 'codegen/metadata'
require 'base64'
require 'codegen/name_mangle'

module StoutLang
  module Ast
    class Def < AstNode
      include Scope
      include NameMangle
      setup :name, :args, :return_type, :block
      attr_accessor :ir
      attr_reader :func_serialized

      def type
        return_type
      end

      def prepare
        super

        self.args.map(&:prepare)
        self.args = args.map(&:resolve)
        # self.return_type = return_type.resolve if return_type

        # Register the Arg's in scope, we can't bind them yet because we don't have a function until codegen
        args.map do |arg|
          register_in_scope(arg.name.name, arg)
        end
        block.prepare

        func_serialized = {name: name, }

        # Def's should register themselves in the parent scope
        parent_scope.register_identifier(name, self)
      end

      def effects
        block.expressions.map do |exp|
          exp.effects
        end.flatten.uniq
      end

      def run
        # for dev, we don't run it when we define it, only when we call it
      end

      def codegen(compile_jit, mod, func, bb)
        func_args = args.map do |arg|
          arg.type_sig.codegen(compile_jit, mod, func, bb)
        end

        # Add the function to the module's metadata
        # Metadata.add(mod, 'sl.funcs', self.func_serialized)

        if return_type.nil?
          # TODO:
          raise "Return types are required right now"
        end
        return_type_ir = return_type.resolve.codegen(compile_jit, mod, func, bb)

        last_expr = nil
        func = mod.functions.add(mangled_name, func_args, return_type_ir) do |function|
          # function.add_attribute :no_unwind_attribute
          function.add_attribute :nounwind
          function.add_attribute :willreturn
          function.add_attribute :mustprogress
          # function.add_attribute :alwaysinline
          # function.linkage = :external

          self.args.each_with_index do |arg, i|
            # Register the argument in the scope

            # Set the variable name
            function.params[i].name = arg.name.name


            arg.ir = function.params[i]

          end

          # Create a block to do the codegen inside of
          function.basic_blocks.append('entry').build do |bb|
            last_expr = block.codegen(compile_jit, mod, function, bb, true)

            # Return the value of the last expression
            bb.ret(last_expr)
          end
        end

        self.ir = func


        return func
      end
    end
  end
end
