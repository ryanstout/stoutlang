# require 'parser/parse_nodes/parse_nodes'
require 'parser/ast/ast_node'
Dir["#{File.dirname(__FILE__)}/ast/*.rb"].each {|file| require file }
Dir["#{File.dirname(__FILE__)}/../types/*.rb"].each {|file| require file }

require 'treetop'
require 'parser/parser'
require 'itree'

# Import constructs
require 'codegen/constructs/import'
require 'codegen/constructs/return'
require 'codegen/constructs/yield'


# Treetop doesn't follow load path right sometimes
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/infix')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/defs')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/cfuncs')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/methods')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/functions')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/types')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/strings')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/ifs')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/blocks')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/lists')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/structs')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/grammar/instance_vars')
Treetop.load(File.expand_path(File.dirname(__FILE__)) + '/parser')


# Ast nodes need to be in the namespace for treetop
include StoutLang::Ast

module StoutLang
  class ParseError < StandardError
  end

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
        raise ParseError.new(@parser.failure_reason)
      end

      root_ast = ast.to_ast

      # Wrap the root_ast in a Root Struct
      unless options[:wrap_root] == false
        root_struct = StoutLang::Ast::Struct.new(Type.new("Root"), root_ast, root_ast.parse_node)
        root_ast.parent = root_struct
        root_struct.parent = nil
        root_ast = root_struct

        # Register the build in types
        root_ast.register_identifier("Int", StoutLang::Int.new)
        root_ast.register_identifier("Int32", StoutLang::Int32.new)
        root_ast.register_identifier("Int64", StoutLang::Int64.new)
        root_ast.register_identifier("Str", StoutLang::Str.new)
        root_ast.register_identifier("Bool", StoutLang::Bool.new)
        root_ast.register_identifier('Type', StoutLang::TypeType.new)
        # root_ast.register_identifier('->', StoutLang::BlockType.new)

        # Register constructs that get parsed/treated like function calls
        root_ast.register_identifier('return', StoutLang::Return)
        root_ast.register_identifier('import', StoutLang::Import)
        root_ast.register_identifier('yield', StoutLang::Yield)
        # root_ast.register_identifier('(,)', StoutLang::Tuple.new) # The tuple constructor

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
      unless node.parse_node.nil?
        @range_tree.insert(node.parse_node.interval.first, node.parse_node.interval.last, node)
      end

      node.children.each do |child|
        self.build_range_tree(child)
      end
    end

    def nodes_at_cursor(cursor_position)
      return @range_tree.stab(cursor_position)
    end
  end
end
