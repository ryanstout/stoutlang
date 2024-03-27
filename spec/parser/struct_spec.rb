require 'spec_helper'

describe StoutLangParser do
  describe "structs" do
    it 'should parse a struct' do
      ast = Ast.new.parse("struct Person { 5 }", root: 'struct')
    end
  end
end
