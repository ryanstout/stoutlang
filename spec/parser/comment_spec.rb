require 'spec_helper'

describe StoutLangParser do
  describe "comments" do
    it 'should parse comments' do
      ast = Ast.new.parse('# this is a comment')

      expect(ast).to eq(Block.new(expressions=[]))
    end

    it 'should parse a comment, then an expression' do
      ast = Ast.new.parse("# this is a comment\n10")

      expect(ast).to eq(Block.new(expressions=[IntegerLiteral.new(value=10)]))
    end
  end
end
