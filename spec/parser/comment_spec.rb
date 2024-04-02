require 'spec_helper'

describe StoutLangParser do
  describe "comments" do
    it 'should parse comments' do
      ast = Parser.new.parse('# this is a comment', {wrap_root: false})

      expect(ast).to eq(Block.new(expressions=[]))
    end

    it 'should parse a comment, then an expression' do
      ast = Parser.new.parse("# this is a comment\n10", {wrap_root: false})

      expect(ast).to eq(Block.new(expressions=[IntegerLiteral.new(value=10)]))
    end
  end
end
