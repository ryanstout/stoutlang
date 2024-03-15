require 'spec_helper'

describe StoutLangParser do
  describe "methods" do
    it 'should parse method arguments' do

      ast = Ast.new.parse('(awesome.dude(), cool)', root: 'method_args')

      match_ast = [FunctionCall.new(name="dude", args=[Identifier.new(name="awesome")]), Identifier.new(name="cool")]
      expect(ast).to eq(match_ast)

    end

    it 'should handle methods with block arguments' do
      ast = Ast.new.parse('awesome.dude() { cool }')

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

    it 'should parse method arguments' do
      ast = Ast.new.parse('awesome.ok', root: 'expression')

      match_ast = FunctionCall.new(
        name="ok",
        args=[
          Identifier.new(name="awesome")
        ]
      )

      expect(ast).to eq(match_ast)

      ast = Ast.new.parse('awesome.dude(ok.dokey()).yeppers', root: 'expression')

      match_ast = FunctionCall.new(
        name="yeppers",
        args=[
          FunctionCall.new(
            name="dude",
            args=[
              Identifier.new(name="awesome"),
              FunctionCall.new(name="dokey", args=[Identifier.new(name="ok")])
            ]
          )
        ]
      )
    end
  end
end
