require 'codegen/constructs/import'
require 'codegen/constructs/construct'

module StoutLang
  module Ast
    class FunctionCall < AstNode

      OPERATORS = ['+', '-', '*', '/', '||', '&&', '|', '&']
      setup :name, :args

      def inspect_always_wrap?
        true
      end

      def prepare
        args.each(&:prepare)
        self.args = args.map(&:resolve)
      end

      def run
        if OPERATORS.include?(name)
          args.map(&:run).reduce(name)
        else
          raise "Not implemented"
        end
      end

      def effects
        if name == 'emit'
          # Emit gets handled directly for now

          # The first argument is the effect
          effect_type = args[0].run

          return [effect_type]
        else
          # Find the function in scope, and return its effects
          function = lookup_function(name, arg_types)

          if function && function.is_a?(Def)
            function.effects.uniq
          else
            []
          end
        end
      end

      def arg_types
        args.map(&:type)
      end

      def type
        # The return type of the function
        function = lookup_function(name, arg_types)
        unless function
          raise "Unable to find function #{name} in scope for #{self.inspect}"
        end
        function.return_type
      end

      def codegen(compile_jit, mod, func, bb)
        # inspect_scope
        method_call = lookup_function(name, arg_types)

         # check if method call (which may be a construct Class) inherits from Construct
        if method_call.is_a?(Class) && method_call < Construct
          # TEMP: Special handler for imports to call into ruby to do imports
          import = method_call.new
          import.parent = self
          import.codegen(compile_jit, mod, func, bb, self)
          return nil
        end

        unless method_call
          raise "Unable to find function #{name} in scope for #{self.inspect}"
        end

        args = self.args.map do |arg|
          arg.codegen(compile_jit, mod, func, bb)
        end

        # method_call_ir = method_call.ir

        # TODO: Because of low level memory issues I think, we need to re-lookup the function in the current module
        # NOTE: This means function names need to be unique

        method_call_ir = mod.functions.named(method_call.mangled_name)

        if method_call_ir.nil?
          puts mod
        end
        # method_call_ir = method_call.ir

        if method_call_ir.nil?
          # puts mod
          # mod.functions.each do |f|
          #   puts "FUNCTION: #{f.name}"
          # end
          raise "Could not find function #{name}"
        end

        if name == 'new'
          # If we're calling new, allocate the memory for a struct of the first arguments type.
          # Then pass that in as the first argument.
          #
          # NOTE: We do this at the call site because it's easier to elide the malloc if it doesn't leak out of the scope.

          # Get the type of the first argument
          struct_type = self.args[0].type

          # Get the size of the struct
          size = struct_type.resolve.bytesize(compile_jit)

          # Allocate the memory for the struct
          # malloc = mod.functions["malloc"]
          malloc = lookup_identifier('malloc').ir
          size = 8
          struct_ptr = bb.call(malloc, LLVM::Int32.from_i(size), "struct_malloc")

          # Pass the struct pointer as the first argument, replace the first
          # argument with the pointer
          args = [struct_ptr] + args[1..-1]
        end

        return bb.call(method_call_ir, *args, assignment_name || 'temp')
      end
    end
  end
end
