require 'spec_helper'

describe StoutLangParser do
  describe "booleans" do
    it 'should parse a true literal' do
      ast = Parser.new.parse('true')
      match_ast = Block.new(expressions=[TrueLiteral.new()])

      expect(ast).to eq(match_ast)
    end

    it 'should parse a false literal' do
      ast = Parser.new.parse('false')
      match_ast = Block.new(expressions=[FalseLiteral.new()])

      expect(ast).to eq(match_ast)
    end
  end
end
