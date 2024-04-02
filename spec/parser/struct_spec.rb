require 'spec_helper'

describe StoutLangParser do
  describe "structs" do
    it 'should parse a struct' do
      ast = Parser.new.parse("struct Person {\n  5\n}", root: 'struct', wrap_root: false)

      expect(ast).to eq(StoutLang::Ast::Struct.new(
          name=Type.new(name="Person"),
          block=Block.new(expressions=[IntegerLiteral.new(value=5)])
        ))
    end

    it 'should parse a struct, then an expression' do
      ast = Parser.new.parse("struct Person {\n  5\n}\n10", wrap_root: false)

      expect(ast).to eq(Block.new(
        expressions=[
          StoutLang::Ast::Struct.new(
            name=Type.new(name="Person"),
            block=Block.new(expressions=[IntegerLiteral.new(value=5)])
          ),
          IntegerLiteral.new(value=10)
        ]
      ))
    end
  end
end
