require 'treetop'
require 'parser/parser'

Treetop.load('parser/parser')

class Ast
  def initialize
    @parser = StoutLangParser.new
  end

  def parse(code)
    ast = @parser.parse(code)

    if ast.nil?
      puts @parser.failure_reason
      # binding.irb
      raise @parser.failure_reason
    end

    return ast

    self.clean_tree(ast)

    return ast.to_ast
  end

  def clean_tree(root_node)
    return if(root_node.elements.nil?)
    root_node.elements.delete_if{|node| !node.is_a?(StoutLang::ParseNode) }
    root_node.elements.each {|node| self.clean_tree(node) }
  end
end
