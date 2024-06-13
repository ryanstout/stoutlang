require 'spec_helper'

describe StoutLangParser do
  describe "booleans" do
    it 'should parse a true literal' do
      ast = Parser.new.parse('true', {wrap_root: false})
      match_ast = Exps.new([TrueLiteral.new()])

      expect(ast).to eq(match_ast)
    end

    it 'should parse a false literal' do
      ast = Parser.new.parse('false', {wrap_root: false})
      match_ast = Exps.new([FalseLiteral.new()])


      expect(ast).to eq(match_ast)
    end
  end
end
