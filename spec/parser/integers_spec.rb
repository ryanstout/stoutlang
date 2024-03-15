require 'spec_helper'

describe StoutLangParser do
  describe "integers" do

    it 'should parse integers' do
      ast = Ast.new.parse('20')
      expect(ast).to eq(Block.new(expressions=[IntegerLiteral.new(value=20)]))
    end

    it 'should handle negative and positive integers' do
      ast = Ast.new.parse('-20')
      expect(ast).to eq(Block.new(expressions=[IntegerLiteral.new(value=-20)]))

      ast = Ast.new.parse('+20')
      expect(ast).to eq(Block.new(expressions=[IntegerLiteral.new(value=20)]))
    end
  end
end
