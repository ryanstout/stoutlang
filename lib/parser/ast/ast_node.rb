# The base class for an AST node
require 'parser/ast/utils/scope'
require 'parser/ast/utils/ast_scope'

module StoutLang
  module Ast
    class AstNode
      include AstScope

      attr_reader :parse_node
      attr_accessor :parent

      # When we compare nodes, we care if they are the same content, not if they are in the same location
      def ==(other)
        return false unless other.is_a?(self.class)

        (instance_variables - [:@parse_node, :@parent]).all? do |var|
          instance_variable_get(var) == other.instance_variable_get(var)
        end
      end

      def prepare
        # Override this method to do any preparation before running the node
      end

      def effects
        []
      end


      def children
        instance_variables.reject { |k| [:@parse_node, :@parent].include?(k) }.map do |var|
          ivar = instance_variable_get(var)

          if ivar.is_a?(AstNode)
            ivar
          elsif ivar.is_a?(Array)
            ivar.select { |e| e.is_a?(AstNode) }
          else
            []
          end
        end.flatten
      end

      def assign_parent!(ast_node, parent)
        if ast_node.is_a?(AstNode)
          ast_node.parent = parent
        elsif ast_node.is_a?(Array)
          # Recursively assign
          ast_node.each { |e| assign_parent!(e, parent) }
        end
      end

      # Takes in a list of properties and creates an initializer for the AstNode. It also creates a property for
      # parse_node. It assigns parent to any AstNode or list of AstNode arguments.
      def self.setup(*properties)
        attr_reader(*properties)

        define_method(:initialize) do |*args|
          index = 0
          properties.each do |prop|
            ast_node = args[index]

            # Assign the parent on any passed in ast nodes
            assign_parent!(ast_node, self)

            instance_variable_set("@#{prop}", ast_node)
            index += 1
          end

          [:parse_node].each do |prop|
            instance_variable_set("@#{prop}", args[index])
          end
        end

      end


      def inspect_always_wrap?
        false
      end

      #
      def dump_ast_internals(obj, total_chars, indent=0, max_width=120, indent_first_line=true, abort_on_overflow=false)
        is_array = obj.is_a?(Array)

        map_over = is_array ? obj : obj.instance_variables.reject {|iv| [:@parse_node, :@parent].include?(iv) }
        char_overflow = false

        var_inspects = []
        map_over.each.with_index do |var_name, index|
          cur_indent = (index == 0 && !indent_first_line) ? 0 : indent
          if is_array
            str = (" " * cur_indent) + dump_ast(var_name, cur_indent, max_width=max_width)
          else
            str = (" " * cur_indent) + "#{var_name[1..-1]}=#{dump_ast(obj.instance_variable_get(var_name), cur_indent, max_width=max_width)}"
          end
          total_chars += str.size

          # If we pass the max chars on a single line, break
          if total_chars > max_width || str.include?("\n")
            if abort_on_overflow
              return [], true
            else
              char_overflow = true
            end
          end

          var_inspects << str
        end

        return var_inspects, char_overflow
      end

      # A pretty printer for the AST, wraps when it should and doesn't when it
      # shouldn't.
      def dump_ast(obj, indent=0, max_width=120, indent_first_line=true)
        out = ""

        is_array = obj.is_a?(Array)
        class_name = obj.class.name.split("::").last.strip

        if obj.is_a?(AstNode) || is_array
          # First log the instance variables, if they are more than 120 - indent chars, put each on its own line
          total_chars = 0
          char_cut_off = (max_width - indent - class_name.size - 2)

          var_inspects, char_overflow = dump_ast_internals(obj, total_chars, 0, char_cut_off, indent_first_line=false, abort_on_overflow=true)

          unless is_array
            out << "#{class_name}.new"
          end

          start_char = is_array ? "[" : "("
          end_char = is_array ? "]" : ")"

          if char_overflow# || (!is_array && obj.inspect_always_wrap?)
            var_inspects, _ = dump_ast_internals(obj, total_chars, indent+2, max_width, indent_first_line=true, abort_on_overflow=false)

            out << "#{start_char}\n"
            out << var_inspects.join(",\n")
            out << "\n#{" " * ([indent, 0].max)}#{end_char}"
          else
            out << start_char
            out << var_inspects.join(", ")
            out << end_char
          end
        else
          out << obj.inspect
        end

        return out
      end


      def inspect(indent=0, max_width=80)
        return dump_ast(self, indent, max_width)
      end
    end

  end
end
