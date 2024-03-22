require 'treetop'
require 'parser/parser'

Treetop.load('parser/grammar/methods')
Treetop.load('parser/grammar/functions')
Treetop.load('parser/grammar/types')
Treetop.load('parser/grammar/strings')
Treetop.load('parser/grammar/ifs')
Treetop.load('parser/grammar/lists')
Treetop.load('parser/parser')


class Ast
  def initialize
    @parser = StoutLangParser.new
  end

  def parse(code, options={})
    ast = @parser.parse(code, options)

    if ast.nil?
      puts @parser.failure_reason
      raise @parser.failure_reason
    end

    return ast.to_ast

    # self.clean_tree(ast)

    # return ast.to_ast
  end

  def clean_tree(root_node)
    return if(root_node.elements.nil?)
    root_node.elements.delete_if{|node| !node.is_a?(StoutLang::ParseNode) }
    root_node.elements.each {|node| self.clean_tree(node) }
  end
end
