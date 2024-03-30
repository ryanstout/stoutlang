require 'spec_helper'

describe StoutLangParser do
  describe "floats" do
    it 'should parse floats' do
      ast = Parser.new.parse('20.5')
      expect(ast).to eq(Block.new(expressions=[FloatLiteral.new(value=20.5)]))
    end

    it 'should parse floats with an exponent term' do
      ast = Parser.new.parse('20.5e10')
      expect(ast).to eq(Block.new(expressions=[FloatLiteral.new(value=20.5e10)]))
    end

    it 'should handle negative floats with an exponent term' do
      ast = Parser.new.parse('-20.5e10')
      expect(ast).to eq(Block.new(expressions=[FloatLiteral.new(value=-20.5e10)]))
    end

    it 'should handle floats with a plus in front' do
      ast = Parser.new.parse('+20.5e10')
      expect(ast).to eq(Block.new(expressions=[FloatLiteral.new(value=20.5e10)]))
    end

    it 'should handle floats with a negative exponent' do
      ast = Parser.new.parse('20.5e-10')
      expect(ast).to eq(Block.new(expressions=[FloatLiteral.new(value=20.5e-10)]))
    end
  end
end
