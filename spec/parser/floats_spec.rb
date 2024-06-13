require 'spec_helper'

describe StoutLangParser do
  describe "floats" do
    it 'should parse floats' do
      ast = Parser.new.parse('20.5', {wrap_root: false})
      expect(ast).to eq(Exps.new(expressions=[FloatLiteral.new(value=20.5)]))
    end

    it 'should parse floats with an exponent term' do
      ast = Parser.new.parse('20.5e10', {wrap_root: false})
      expect(ast).to eq(Exps.new(expressions=[FloatLiteral.new(value=20.5e10)]))
    end

    it 'should handle negative floats with an exponent term' do
      ast = Parser.new.parse('-20.5e10', {wrap_root: false})
      expect(ast).to eq(Exps.new(expressions=[FloatLiteral.new(value=-20.5e10)]))
    end

    it 'should handle floats with a plus in front' do
      ast = Parser.new.parse('+20.5e10', {wrap_root: false})
      expect(ast).to eq(Exps.new(expressions=[FloatLiteral.new(value=20.5e10)]))
    end

    it 'should handle floats with a negative exponent' do
      ast = Parser.new.parse('20.5e-10', {wrap_root: false})
      expect(ast).to eq(Exps.new(expressions=[FloatLiteral.new(value=20.5e-10)]))
    end
  end
end
