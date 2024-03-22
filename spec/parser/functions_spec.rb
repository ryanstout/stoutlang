require 'spec_helper'

describe StoutLangParser do
  describe "functions" do
    it 'should parse function calls' do
      ast = Ast.new.parse('print()', root: 'function_call')

      expect(ast).to eq(FunctionCall.new(name="print", args=[]))
    end

    it 'should parse function call with arguments' do
      ast = Ast.new.parse('print(1, 2)', root: 'function_call')

      expect(ast).to eq(FunctionCall.new(name="print", args=[IntegerLiteral.new(value=1), IntegerLiteral.new(value=2)]))
    end
  end
end
