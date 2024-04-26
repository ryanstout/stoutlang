require 'parser/ast/utils/scope'
require 'codegen/metadata'
require 'base64'

module StoutLang
  module Ast
    class Def < AstNode
      include Scope
      setup :name, :args, :return_type, :block
      attr_accessor :ir
      attr_reader :func_serialized

      def prepare
        super

        self.args = args.map(&:resolve)
        self.return_type = return_type.resolve if return_type

        # Register the DefArg's in scope, we can't bind them yet because we don't have a function until codegen
        args.map do |arg|
          register_in_scope(arg.name.name, arg)
        end
        block.prepare

        func_serialized = {name: name, }
        puts "Def: #{name} serialized: #{func_serialized.size}"

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
        return_type_ir = return_type.codegen(compile_jit, mod, func, bb)

        last_expr = nil
        func = mod.functions.add(name, func_args, return_type_ir) do |function|
          function.add_attribute :no_unwind_attribute
          function.linkage = :external

          self.args.each_with_index do |arg, i|
            # Register the argument in the scope
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

    class DefArg < AstNode
      setup :name, :type_sig
      attr_accessor :ir

      def codegen(compile_jit, mod, func, bb)
        self.ir
      end

      def to_h
        {name: name, type: type_sig.to_h}
      end
    end
  end
end
