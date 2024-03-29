require 'treetop'
require 'parser/parser'
require 'itree'

Treetop.load('parser/grammar/methods')
Treetop.load('parser/grammar/functions')
Treetop.load('parser/grammar/types')
Treetop.load('parser/grammar/strings')
Treetop.load('parser/grammar/ifs')
Treetop.load('parser/grammar/lists')
Treetop.load('parser/grammar/structs')
Treetop.load('parser/parser')


class Ast
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

    # After we parse the root_ast, we build a range tree so we can quickly look up each node under a certain cursor
    # position
    self.build_range_tree(root_ast)

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

  def clean_tree(root_node)
    return if(root_node.elements.nil?)
    root_node.elements.delete_if{|node| !node.is_a?(StoutLang::ParseNode) }
    root_node.elements.each {|node| self.clean_tree(node) }
  end
end
