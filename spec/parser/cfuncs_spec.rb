require 'spec_helper'

describe StoutLangParser do
  describe "cfuncs" do
    it 'should parse a cfunc' do
      ast = Parser.new.parse("cfunc puts(s: Str) -> Int")

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name=Type.new(name="Root"),
          block=Block.new(
            expressions=[
              CFunc.new(
                name="puts",
                args=[
                  DefArg.new(
                    name=Identifier.new(name="s"),
                    type_sig=TypeSig.new(type_val=Type.new(name="Str"))
                  )
                ],
                return_type=Type.new(name="Int")
              )
            ],
            args=nil
          )
        )
      )
    end
  end
end
