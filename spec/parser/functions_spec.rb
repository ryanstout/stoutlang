require 'spec_helper'

describe StoutLangParser do
  describe "functions" do
    it 'should parse function calls' do
      ast = Parser.new.parse('print()', root: 'function_call_with_args', wrap_root: false)

      expect(ast).to eq(FunctionCall.new(name="print", args=[]))
    end

    it 'should parse function call with arguments' do
      ast = Parser.new.parse('print(1, 2)', root: 'function_call_with_args', wrap_root: false)

      expect(ast).to eq(FunctionCall.new(name="print", args=[IntegerLiteral.new(value=1), IntegerLiteral.new(value=2)]))
    end

    it 'should allow function calls from the root' do
      ast = Parser.new.parse('print()', wrap_root: false)
      expect(ast).to eq(Block.new(expressions=[FunctionCall.new(name="print", args=[])]))

    end

    it 'should parse functions after some method calls' do
      ast = Parser.new.parse("a = 5\n5.name()\nprint(\"Hello\").to_i()", wrap_root: false)

      expect(ast).to eq(
        Block.new(
          expressions=[
            Assignment.new(
              identifier=Identifier.new(name="a"),
              expression=IntegerLiteral.new(value=5),
              type_sig=nil
            ),
            FunctionCall.new(name="name", args=[IntegerLiteral.new(value=5)]),
            FunctionCall.new(
              name="to_i",
              args=[
                FunctionCall.new(name="print", args=[StringLiteral.new(value=["Hello"])])
              ]
            )
          ]
        )
      )
    end
  end
end
