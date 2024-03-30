require 'spec_helper'

describe StoutLangParser do
  describe "functions" do
    it 'should parse function calls' do
      ast = Parser.new.parse('print()', root: 'function_call_with_args')

      expect(ast).to eq(FunctionCall.new(name="print", args=[]))
    end

    it 'should parse function call with arguments' do
      ast = Parser.new.parse('print(1, 2)', root: 'function_call_with_args')

      expect(ast).to eq(FunctionCall.new(name="print", args=[IntegerLiteral.new(value=1), IntegerLiteral.new(value=2)]))
    end

    it 'should allow function calls from the root' do
      ast = Parser.new.parse('print()')
      expect(ast).to eq(Block.new(expressions=[FunctionCall.new(name="print", args=[])]))

    end
  end
end
