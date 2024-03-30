require 'spec_helper'

describe StoutLangParser do
  describe "methods" do
    it 'should parse method arguments' do

      ast = Parser.new.parse('(awesome.dude(), cool)', root: 'method_args')

      match_ast = [FunctionCall.new(name="dude", args=[Identifier.new(name="awesome")]), Identifier.new(name="cool")]
      expect(ast).to eq(match_ast)

    end

    it 'should handle methods with block arguments' do
      ast = Parser.new.parse('awesome.dude() { cool }')

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
      ast = Parser.new.parse('awesome.ok')

      match_ast = Block.new(
        expressions=[
          FunctionCall.new(name="ok", args=[
            Identifier.new(name="awesome")
          ]
        )]
      )

      expect(ast).to eq(match_ast)
    end

    it 'should parse complex method calls' do

      ast = Parser.new.parse('awesome.dude(ok.dokey()).yeppers', root: 'expression')

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

  it 'should handle empty method args' do
    ast = Parser.new.parse('()', root: 'method_args')

    expect(ast).to eq([])

  end

  it 'should define methods' do
    code = <<-END
    def some_method(arg1, arg2) {
      print()
    }
    END
    ast = Parser.new.parse(code.strip)

    expect(ast).to eq(Block.new(
      expressions=[
        Def.new(
          name="some_method",
          args=[Identifier.new(name="arg1"), Identifier.new(name="arg2")],
          block=Block.new(expressions=[FunctionCall.new(name="print", args=[])])
        )
      ]
    )  )
  end
end
