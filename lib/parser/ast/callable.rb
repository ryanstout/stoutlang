# A Callable is a base class for Def and Block. It handles registering arguments, type, and return types.

require "parser/ast/utils/scope"
require "codegen/metadata"
require "base64"
require "codegen/name_mangle"

module StoutLang
  module Ast
    class Callable < AstNode
      include Scope
      include NameMangle
      setup :name, :args, :return_type, :body
      attr_accessor :ir

      def type
        # The type of a def/block is either the specified return type or the type of the last expression
        raise "Not implemented"
      end

      def return_type
        @return_type || body.type
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
        body.prepare
      end

      def effects
        body.effects
      end

      def self.ast_props
        @ast_props || superclass.ast_props
      end

      def run
        # for dev, we don't run it when we define it, only when we call it
      end

      def codegen(compile_jit, mod, func, bb)
        func_args = args.map do |arg|
          arg.type_sig.codegen(compile_jit, mod, func, bb)
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

          # Create a body to do the codegen inside of
          function.basic_blocks.append("entry").build do |bb|
            last_expr = body.codegen(compile_jit, mod, function, bb)

            # Return the value of the last expression
            last_block = function.basic_blocks.last
            last_instruct = last_block.instructions.last
            if !last_expr.is_a?(Return) && (!last_instruct || last_instruct.opcode != :ret)
              bb.ret(last_expr)
            end
          end
        end

        self.ir = func

        return func
      end
    end
  end
end
