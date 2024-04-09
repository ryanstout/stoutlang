module StoutLang
  module Ast
    class StringLiteral < AstNode
      setup :value

      def run
        value.map do |v|
          if v.is_a?(String)
            v
          else
            v.run
          end
        end.join("")
      end

      def find_parent_assignement
        parent = self.parent
        while parent
          if parent.is_a?(Assignment)
            return parent
          elsif parent.is_a?(Scope)
            return nil
          end
          parent = parent.parent
        end
        return nil
      end

      def codegen(mod, func, bb)
        str = self.run()

        # Get the variable name by walking up the parent chain until we find an assignment, stop if we get to a Scope
        assignment = find_parent_assignement()

        if assignment
          var_name = assignment.identifier.name
        else
          var_name = "strliteral"
        end

        str_ptr = LLVM::ConstantArray.string(str)

        mod.globals.add(str_ptr, var_name) do |var|
          var.linkage = :private
          var.global_constant = true
          var.unnamed_addr = true
          var.initializer = str_ptr
        end
      end
    end

    class StringInterpolation < AstNode
      setup :block

      def prepare
        block.prepare
      end

      def run
        block.run.to_s
      end
    end
  end
end
