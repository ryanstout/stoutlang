require 'spec_helper'

describe StoutLangParser do

  describe "programs" do
    it 'should parse multiple lines' do
      ast = Parser.new.parse("5\n10", wrap_root: false)
      expect(ast).to eq(
        Block.new(expressions=[IntegerLiteral.new(value=5), IntegerLiteral.new(value=10)])
      )
    end

    it 'should parse multiple lines2' do
      ast = Parser.new.parse("a = 5\nb = 10\nc = a + b", wrap_root: false)
      expect(ast).to eq(
        Block.new(
         expressions=[
           Assignment.new(
             identifier=Identifier.new(name="a"),
             expression=IntegerLiteral.new(value=5),
             type_sig=nil
           ),
           Assignment.new(
             identifier=Identifier.new(name="b"),
             expression=IntegerLiteral.new(value=10),
             type_sig=nil
           ),
           Assignment.new(
             identifier=Identifier.new(name="c"),
             expression=FunctionCall.new(name="+", args=[Identifier.new(name="a"), Identifier.new(name="b")]),
             type_sig=nil
           )
         ]
       )
      )
    end
  end

  it 'should parse blocks with only expressions' do
    ast = Parser.new.parse("{ 5 }", root: 'block', wrap_root: false)
    expect(ast).to eq(
      Block.new(expressions=[IntegerLiteral.new(value=5)])
    )
  end
end
