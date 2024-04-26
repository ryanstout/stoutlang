require 'spec_helper'

describe StoutLangParser do
  describe "macros" do
    it 'should define macros' do
      ast = Parser.new.parse("macro awesome {\n  5\n}", wrap_root: false)

      expect(ast).to eq(
        Block.new(
          expressions=[
            Macro.new(
              name="awesome",
              args=[],
              return_type=nil,
              block=Block.new(expressions=[IntegerLiteral.new(value=5)])
            )
          ]
        )
      )
    end
  end

  it 'should define macros with arguments' do
    ast = Parser.new.parse("macro awesome(a, b) {\n  5\n}", root: 'macro_define', wrap_root: false)

    expect(ast).to eq(
      Macro.new(
        name="awesome",
        args=[
          Arg.new(name=Identifier.new(name="a"), type_sig=nil),
          Arg.new(name=Identifier.new(name="b"), type_sig=nil)
        ],
        return_type=nil,
        block=Block.new(expressions=[IntegerLiteral.new(value=5)])
      )
    )
  end

  it 'should let you define a macro with a return type' do
    ast = Parser.new.parse("macro awesome(a, b) -> Int {\n  5\n}", root: 'macro_define', wrap_root: false)

    expect(ast).to eq(
      Macro.new(
        name="awesome",
        args=[
          Arg.new(name=Identifier.new(name="a"), type_sig=nil),
          Arg.new(name=Identifier.new(name="b"), type_sig=nil)
        ],
        return_type=Type.new(name="Int"),
        block=Block.new(expressions=[IntegerLiteral.new(value=5)])
      )
    )
  end
end
