require 'spec_helper'

describe StoutLangParser do
  describe "blocks" do

    it 'should handle methods with block arguments' do
      ast = Parser.new.parse('awesome.dude() { cool }', wrap_root: false)

      match_ast = Block.new(
          expressions=[
            FunctionCall.new(
              name="dude",
              args=[
                Identifier.new(name="awesome"),
                Block.new(expressions=[Identifier.new(name="cool")])
              ]
            )
          ]
        )
      expect(ast).to eq(match_ast)
    end

    it 'should let you call a function with 0 or 1 arg without parens and a block argument' do
      ast = Parser.new.parse('awesome.dude { cool }', wrap_root: false)

      match_ast = Block.new(
          expressions=[
            FunctionCall.new(
              name="dude",
              args=[
                Identifier.new(name="awesome"),
                Block.new(expressions=[Identifier.new(name="cool")])
              ]
            )
          ]
        )
      expect(ast).to eq(match_ast)

      # TODO: Kind of feels like this should require parens?
      ast = Parser.new.parse('awesome.dude 1 { cool }', wrap_root: false)

      match_ast = Block.new(
        expressions=[
          FunctionCall.new(
            name="dude",
            args=[
              Identifier.new(name="awesome"),
              IntegerLiteral.new(value=1),
              Block.new(expressions=[Identifier.new(name="cool")])
            ]
          )
        ]
      )
    end

    it 'should replace identifiers that point to a function call with a FunctionCall' do
      code = <<-END
        def one() { 1 }

        one
      END
      ast = Parser.new.parse(code)
      # binding.pry
      ast.prepare

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name=Type.new(name="Root"),
          block=Block.new(
            expressions=[
              Def.new(
                name="one",
                args=[],
                return_type=nil,
                block=Block.new(expressions=[IntegerLiteral.new(value=1)], args=nil)
              ),
              FunctionCall.new(name="one", args=[])
            ],
            args=nil
          )
        )
      )

    end

    it 'should replace identifiers that resolve to functions in arguments' do
      code = <<-END
        def one() { 1 }
        def two() { 2 }

        one(two)
      END
      ast = Parser.new.parse(code)
      ast.prepare

      expect(ast).to eq(
         StoutLang::Ast::Struct.new(
          name=Type.new(name="Root"),
          block=Block.new(
            expressions=[
              Def.new(
                name="one",
                args=[],
                return_type=nil,
                block=Block.new(expressions=[IntegerLiteral.new(value=1)], args=nil)
              ),
              Def.new(
                name="two",
                args=[],
                return_type=nil,
                block=Block.new(expressions=[IntegerLiteral.new(value=2)], args=nil)
              ),
              FunctionCall.new(name="one", args=[FunctionCall.new(name="two", args=[])])
            ],
            args=nil
          )
        )
      )
    end

    # TODO: Add parser support for compile time method calls in type sigs
    # it 'should replace identifiers that resolve to functions in type signatures' do
    #   code = <<-END
    #     def two() { Str }
    #     def one(a: Int | two) { 1 }
    #   END

    #   ast = Parser.new.parse(code)
    #   ast.prepare

    #   expect(ast).to eq(
    #      StoutLang::Ast::Struct.new(
    #       name=Type.new(name="Root"),
    #       block=Block.new(
    #         expressions=[
    #           Def.new(
    #             name="two",
    #             args=[],
    #             return_type=nil,
    #             block=Block.new(expressions=[Type.new(name="Str")], args=nil)
    #           ),
    #           Def.new(
    #             name="one",
    #             args=[
    #               DefArg.new(
    #                 name=Identifier.new(name="a"),
    #                 type_sig=TypeSig.new(type_val=Type.new(name="Int") | Type.new(name="two"))
    #               )
    #             ],
    #             return_type=nil,
    #             block=Block.new(expressions=[IntegerLiteral.new(value=1)], args=nil)
    #           )
    #         ],
    #         args=nil
    #       )
    #     )
    #   )
    # end

  end
end