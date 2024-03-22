require 'spec_helper'

describe StoutLangParser do
  describe "comments" do
    it 'should parse comments' do
      ast = Ast.new.parse('# this is a comment')

      expect(ast).to eq(Block.new(expressions=[Comment.new(comment=" this is a comment")]))
    end
  end
end
