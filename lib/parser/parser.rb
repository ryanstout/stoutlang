# require 'parser/parse_nodes/parse_nodes'
require 'parser/ast/ast_node'
Dir["#{File.dirname(__FILE__)}/ast/*.rb"].each {|file| require file }

require 'treetop'
require 'parser/parser'
require 'itree'

# Treetop doesn't follow load path right sometimes
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/infix')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/defs')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/methods')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/functions')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/types')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/strings')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/ifs')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/lists')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/structs')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/parser')


# Ast nodes need to be in the namespace for treetop
include StoutLang::Ast

module StoutLang
  # include ParseNodes
  class Parser
    attr_reader :ast
    def initialize
      @parser = StoutLangParser.new

      @range_tree = Intervals::Tree.new
    end

    def parse(code, options={})
      ast = @parser.parse(code, options)

      if ast.nil?
        puts @parser.failure_reason
        raise @parser.failure_reason
      end

      root_ast = ast.to_ast

      # Wrap the root_ast in a Root Struct
      unless options[:wrap_root] == false
        root_struct = StoutLang::Ast::Struct.new('Root', root_ast, root_ast.parse_node)
        root_ast.parent = root_struct
        root_struct.parent = nil
        root_ast = root_struct
      end

      # After we parse the root_ast, we build a range tree so we can quickly look up each node under a certain cursor
      # position
      self.build_range_tree(root_ast)

      # Save the AST for later access
      @ast = root_ast

      return root_ast

    end

    def build_range_tree(node)
      return unless node.is_a?(AstNode)
      if node.parse_node.nil?
        raise "Node has no parse node: #{node.inspect}"
      end
      @range_tree.insert(node.parse_node.interval.first, node.parse_node.interval.last, node)

      node.children.each do |child|
        self.build_range_tree(child)
      end
    end

    def nodes_at_cursor(cursor_position)
      return @range_tree.stab(cursor_position)
    end
  end
end
