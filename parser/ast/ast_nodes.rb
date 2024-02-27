# The base class for an AST node

module StoutLang
  module Ast
    class AstNode
      attr_reader :parse_node
      attr_reader :children

      def inspect_internal(indent="")
        ""
      end

      def inspect(indent="")
        out = []
        out << "#{indent}<#{self.class.name.split("::").last.strip} #{inspect_internal(indent+"  ")}"
        if children
          children_inspect = children.map {|c| c.inspect(indent + "  ") }
          out << "\n#{children_inspect.join("\n")}\n"
          out << indent
        end
        out << ">"
        return out.join("")
      end
    end

    class Identifier < AstNode
      attr_reader :name

      def initialize(name, parse_node=nil)
        @name = name
        @parse_node = parse_node
      end

      def inspect(indent="")
        @name
      end
    end

    class IntegerLiteral < AstNode
      def initialize(value, parse_node=nil)
        @value = value
        @parse_node = parse_node
      end

      def inspect(indent="")
        @value.to_s
      end
    end

    class FloatLiteral < AstNode
      def initialize(value, parse_node=nil)
        @value = value
        @parse_node = parse_node
      end

      def inspect(indent="")
        @value.to_s
      end
    end

    class StringLiteral < AstNode
      def initialize(value, parse_node=nil)
        @value = value
        @parse_node = parse_node
      end

      def inspect(indent="")
        @value
      end
    end

    class NilLiteral < AstNode
      def initialize(parse_node=nil)
        @parse_node = nil
      end

      def inspect(indent="")
        'nil'
      end
    end

    class Expression < AstNode
      # Takes a list of child ast nodes
      def initialize(expression, parse_node=nil)
        @expression = expression
        @parse_node = parse_node
      end
    end

    class Assignment < AstNode
      def initialize(identifier, expression, parse_node=nil)
        @identifier = identifier
        @expression = expression
        @parse_node = parse_node
      end

      def inspect_internal(indent="")
        "#{@identifier.name} = #{@expression.inspect(indent)}"
      end
    end

    class MainCode < AstNode
      def initialize(children, parse_node=nil)
        @children = children
        @parse_node = parse_node
      end
    end

    class Comment < AstNode
      def initialize(comment, parse_node=nil)
        @comment = comment
        @parse_node = parse_node
      end
    end

    class MethodChain < AstNode
      def initialize(method_calls, parse_node=nil)
        @children = method_calls
        @parse_node = parse_node
      end
    end

    class MethodCall < AstNode
      def initialize(identifier, method_name, args, parse_node=nil)
        @identifier = identifier
        @method_name = method_name
        @args = args
        @parse_node = parse_node
      end

      def inspect_internal(indent="")
        "#{@identifier.inspect(indent)}( #{@args.inspect} )"
      end
    end
  end
end