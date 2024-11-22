require "parser/ast/callable"

module StoutLang
  module Ast
    class Block < Callable
      setup :args, :body

      def prepare
        super

        # The way closures work in stoutlang is that we make a copy of all values referenced in the block and
        # register them in the scope.

        # Find all LocalVal's in the body
        # locals = body.expressions.select { |exp| exp.is_a?(LocalVal) }

        # @closure_vars = []
        # locals.each do |local|
        #   # Create a new LocalVal with the same name, but a new name
        #   new_local = LocalVal.new(local.name)
        #   new_local.parent = local.parent
        #   new_local.prepare
        #   closure_vars << new_local

        #   # Register the new local in the scope
        #   register_in_scope(new_local.name, new_local)
        # end
      end

      def type
        # The type of a block is a BlockType, which should match the BlockType
        # on the function being called
        args = self.args.map { |arg| arg.resolve.type }
        return_type = self.return_type

        return BlockType.new(args, return_type).assign_parent!(self)
      end

      def codegen(compile_jit, mod, func, bb)
        # Set up the IR for each local variable in the closure.
        # @closure_vars.each do |local|
        #   # Lookup the original value
        # end

        super
      end

      def return_type
        @return_type || body.type
      end

      def name
        # TODO: For now we just use a guid for the block name. But we should do a self incrementing and
        # make sure these are unique (and maybe dedup if we have the same block expressions/args)
        @name ||= "__block_#{rand(4_000_000_000)}"
      end
    end
  end
end
