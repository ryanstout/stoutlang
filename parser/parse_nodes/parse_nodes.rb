require 'parser/ast/ast_nodes'

module StoutLang
  module ParseNodes    
    module NodeInspect

      def children
        # elements that are children of ParseNode
        @elements.select {|e| e.is_a?(ParseNode) }
      end

      def to_ast
        raise "to_ast not implemented on #{self.class.name}"
      end

      def inspect_internal(indent="")
        ""
      end

      def inspect(indent="")
        children_inspect = children.map {|c| c.inspect(indent + "  ") }
        out = []
        out << "#{indent}<#{self.class.name.split("::").last.strip} #{inspect_internal(indent+"  ")}"
        out << "\n#{children_inspect.join("\n")}\n" if children_inspect.size > 0
        out << indent if children_inspect.size > 0
        out << ">"
        return out.join("")
      end
    end

    class ParseNode < Treetop::Runtime::SyntaxNode
      include NodeInspect
      def initialize(*args)
        puts "Init: #{self.class.name} -- #{args.inspect}"
        super
        # puts "Created"
      end


    end

    class IntegerLiteral < ParseNode
      def inspect_internal(indent="")
        text_value.to_i
      end

      def to_ast
        StoutLang::Ast::IntegerLiteral.new(text_value.to_i, self)
      end
    end

    class StringLiteral < ParseNode
      def inspect_internal(indent="")
        "#{text_value}"
      end
    end

    class FloatLiteral < ParseNode
      def inspect_internal(indent="")
        text_value.to_f
      end
    end

    class Identifier < ParseNode
      def to_ast
        Ast::Identifier.new(text_value, self)
      end

      def inspect_internal(indent="")
        text_value
      end
    end

    class Expression < ParseNode
    end

    # class Body < ParseNode
    # end
    module Body
      include NodeInspect
    end

    class Space < ParseNode
    end

    class NilLiteral < ParseNode
    end

    class Assignment < ParseNode
      def to_ast
        identifier = children[0].to_ast
        raise "First child of assignment operator should be an identifier" unless identifier.is_a?(Ast::Identifier)
        Ast::Assignment.new(identifier, children[1].to_ast, self)
      end
    end

    class MethodChain < ParseNode    
      # def initialize(*args)
      #   puts "METHOD CHAIN: #{args.inspect}"
      #   binding.irb
      #   super
      #   puts "CHILDREN: #{children.inspect}"
      # end

      def to_ast
        # children.map { |c| Ast::MethodCall.new(c.to_ast, c.to_ast, nil, self) }
        Ast::MethodChain.new(children.map {|c| c.to_ast }, self)
      end
    end

    class MethodCall < ParseNode      
      # def initialize(*args)
      #   # puts "METHOD CALL: #{args.inspect}"
      #   super
      #   puts "METHOD CALL: #{method_name.inspect}"
      # end

      def to_ast
        Ast::MethodCall.new(children[0].to_ast, children[1].to_ast, nil, self)
      end
    end
    
    class MethodName < ParseNode
      def inspect_internal(indent="")
        text_value
      end

      def to_ast
        text_value
      end
    end

    class Comment < ParseNode
      def to_ast
        Ast::Comment.new(text_value, self)
      end
    end

    class MainCode < ParseNode
      def to_ast
        Ast::MainCode.new(children.map {|c| c.to_ast }, self)
      end
    end
  end
end