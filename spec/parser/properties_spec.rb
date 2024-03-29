require 'spec_helper'

describe StoutLangParser do
  describe "properties" do
    it 'should parse properties' do
      ast = Ast.new.parse("@name: Str", root: 'property')

      expect(ast).to eq(Property.new(
          name=Identifier.new(name="name"),
          type_sig=TypeSig.new(type_val=Type.new(name="Str"))
        ))
    end

    it 'should let you define properties inside of a struct' do
      ast = Ast.new.parse("struct Person {\n@name: Str\n@age: Int\n}", root: 'struct')

      expect(ast).to eq(StoutLang::Ast::Struct.new(
        name=Type.new(name="Person"),
        block=Block.new(
          expressions=[
            Property.new(
              name=Identifier.new(name="name"),
              type_sig=TypeSig.new(type_val=Type.new(name="Str"))
            ),
            Property.new(
              name=Identifier.new(name="age"),
              type_sig=TypeSig.new(type_val=Type.new(name="Int"))
            )
          ]
        )
      ))
    end
  end
end
