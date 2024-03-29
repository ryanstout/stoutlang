require 'spec_helper'

describe StoutLangParser do
  describe "lists" do
    it 'should parse lists' do
      ast = Ast.new.parse('[1, 2, 3]', root: 'list')
      expect(ast).to eq(
        List.new(
          elements=[
            IntegerLiteral.new(value=1),
            IntegerLiteral.new(value=2),
            IntegerLiteral.new(value=3)
          ]
        )
      )
    end

    it 'should parse nested lists' do
      ast = Ast.new.parse('[[1, 2], [3, 4]]')

      expect(ast).to eq(
        Block.new(
         expressions=[
           List.new(
             elements=[
               List.new(
                 elements=[IntegerLiteral.new(value=1), IntegerLiteral.new(value=2)]
               ),
               List.new(
                 elements=[IntegerLiteral.new(value=3), IntegerLiteral.new(value=4)]
               )
             ]
           )
         ]
       )
      )
    end

    it 'should support assigning lists with type inference' do
      ast = Ast.new.parse('a = [1, 2, 3]')
      expect(ast).to eq(
        Block.new(
          expressions=[
            Assignment.new(
              identifier=Identifier.new(name="a"),
              expression=List.new(
                elements=[
                  IntegerLiteral.new(value=1),
                  IntegerLiteral.new(value=2),
                  IntegerLiteral.new(value=3)
                ]
              ),
              type_sig=nil
            )
          ]
        )
      )
    end
  end
end