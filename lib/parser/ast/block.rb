require 'parser/ast/callable'

module StoutLang
  module Ast
    class Block < Callable
      setup :args, :body
      def prepare
        super
      end

      def type
        # The type of a block is a BlockType, which should match the BlockType
        # on the function being called
        args = self.args.map {|arg| arg.resolve.type }
        return_type = self.return_type

        return BlockType.new(args, return_type).assign_parent!(self)
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
