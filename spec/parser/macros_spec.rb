require 'spec_helper'

describe StoutLangParser do
  describe "macros" do
    it 'should define macros' do
      ast = Parser.new.parse("macro awesome {\n  5\n}")

      expect(ast).to eq(
        Block.new(
          expressions=[
            Macro.new(
              name="awesome",
              args=[],
              block=Block.new(expressions=[IntegerLiteral.new(value=5)])
            )
          ]
        )
      )
    end
  end

  it 'should define macros with arguments' do
    ast = Parser.new.parse("macro awesome(a, b) {\n  5\n}")

    expect(ast).to eq(
      Block.new(
        expressions=[
          Macro.new(
            name="awesome",
            args=[Identifier.new(name="a"), Identifier.new(name="b")],
            block=Block.new(expressions=[IntegerLiteral.new(value=5)])
          )
        ]
      )
    )
  end
end
