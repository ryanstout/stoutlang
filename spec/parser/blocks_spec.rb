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

  end
end
