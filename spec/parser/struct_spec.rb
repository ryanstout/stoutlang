require 'spec_helper'

describe StoutLangParser do
  describe "structs" do
    it 'should parse a struct' do
      ast = Ast.new.parse("struct Person { 5 }", root: 'struct')

      expect(ast).to eq(StoutLang::Ast::Struct.new(
          name=Type.new(name="Person"),
          block=Block.new(expressions=[IntegerLiteral.new(value=5)])
        ))
    end
  end
end
