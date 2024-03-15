require 'spec_helper'

describe StoutLangParser do

  describe "assignment" do
    it 'should parse assignments' do
      ast = Ast.new.parse('a = 10')
      match_ast = Block.new(
        expressions=[
          Assignment.new(
            identifier=Identifier.new(name="a"),
            expression=IntegerLiteral.new(value=10),
            type_defn=nil
          )
        ]
      )
      expect(ast).to eq(match_ast)
    end

    it 'should parse assignments with a type definition' do
      ast = Ast.new.parse('a: Int = 10')
      match_ast = Block.new(
        expressions=[
          Assignment.new(
            identifier=Identifier.new(name="a"),
            expression=IntegerLiteral.new(value=10),
            type_defn=TypeDefn.new(type_val="Int")
          )
        ]
      )
      expect(ast).to eq(match_ast)
    end
  end
end
