require 'spec_helper'

describe StoutLangParser do
  describe "type signatures" do
    it 'should match a type' do
      ast = Parser.new.parse('Int', root: 'type_expression', wrap_root: false)

      expect(ast).to eq(Type.new(name="Int"))

    end
    it 'should parse a type variable' do
      ast = Parser.new.parse('\'tv', root: 'type_primary', wrap_root: false)

      expect(ast).to eq(TypeVariable.new(name="tv"))
    end

    it 'should support infix operators in type signatures' do
      ast = Parser.new.parse('Str | Int', root: 'type_expression', wrap_root: false)

      expect(ast).to eq(FunctionCall.new(
        name="|",
        args=[
          Type.new(name="Str"),
          Type.new(name="Int")
        ]
      ))
    end

    it 'should parse the type sig in a def argument' do
      ast = Parser.new.parse('def say_hi(name: Str) {  }')

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name=Type.new(name="Root", args=nil),
          body=Exps.new(
            [
              Def.new(
                name="say_hi",
                args=[
                  Arg.new(
                    name=Identifier.new(name="name"),
                    type_sig=TypeSig.new(type_val=Type.new(name="Str", args=nil))
                  )
                ],
                return_type=nil,
                body=Exps.new([])
              )
            ]
          )
        )
      )

    end
    it 'should allow infix ops in type signatures' do
      ast = Parser.new.parse('def say_hi(name: Str | Int) {  }')

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name=Type.new(name="Root", args=nil),
          body=Exps.new(
            [
              Def.new(
                name="say_hi",
                args=[
                  Arg.new(
                    name=Identifier.new(name="name"),
                    type_sig=TypeSig.new(
                      type_val=FunctionCall.new(
                        name="|",
                        args=[
                          Type.new(name="Str", args=nil),
                          Type.new(name="Int", args=nil)
                        ]
                      )
                    )
                  )
                ],
                return_type=nil,
                body=Exps.new([])
              )
            ]
          )
        )
      )
    end

    it 'should join multiple type sigs with a comma' do
      ast = Parser.new.parse('def say_hi() -> Int, Int {  }')

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name=Type.new(name="Root", args=nil),
          body=Exps.new(
            [
              Def.new(
                name="say_hi",
                args=[],
                return_type=[Type.new(name="Int", args=nil), Type.new(name="Int", args=nil)],
                body=Exps.new([])
              )
            ]
          )
        )
      )
    end

    # it 'should allow < to show a type variable must extend another type' do
    #   ast = Parser.new.parse("def add(a: 'T < Number, b: 'T < Number) { }")

    #   expect(ast).to eq(
    #     StoutLang::Ast::Struct.new(
    #       name=Type.new("Root"),
    #       block=Block.new(
    #         expressions=[
    #           Def.new(
    #             name="say_hi",
    #             args=[
    #               Arg.new(
    #                 name=Identifier.new(name="name"),
    #                 type_sig=TypeSig.new(
    #                   type_val=FunctionCall.new(
    #                     name="<",
    #                     args=[Type.new(name="Str"), TypeVariable.new(name="tv")]
    #                   )
    #                 )
    #               )
    #             ],
    #             block=Block.new(expressions=[])
    #           )
    #         ],
    #         args=nil
    #       )
    #     )
    #   )
    # end
  end
end
