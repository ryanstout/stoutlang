require 'spec_helper'

describe StoutLangParser do

  describe "assignment" do
    it 'should parse assignments' do
      ast = Parser.new.parse('a = 10', {wrap_root: false})
      match_ast = Block.new(
        expressions=[
          Assignment.new(
            identifier=Identifier.new(name="a"),
            expression=IntegerLiteral.new(value=10),
            type_sig=nil
          )
        ]
      )
      expect(ast).to eq(match_ast)
    end

    it 'should parse assignments with a type definition' do
      ast = Parser.new.parse('a: Int = 10', {wrap_root: false})
      match_ast = Block.new(
        expressions=[
          Assignment.new(
            identifier=Identifier.new(name="a"),
            expression=IntegerLiteral.new(value=10),
            type_sig=TypeSig.new(type_val=Type.new("Int"))
          )
        ]
      )
      expect(ast).to eq(match_ast)
    end
  end
end
