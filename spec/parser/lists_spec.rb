require 'spec_helper'

describe StoutLangParser do
  describe "lists" do
    it 'should parse lists' do
      ast = Parser.new.parse('[1, 2, 3]', root: 'list', wrap_root: false)
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
      ast = Parser.new.parse('[[1, 2], [3, 4]]', wrap_root: false)

      expect(ast).to eq(
        Exps.new(
          [
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
      ast = Parser.new.parse('a = [1, 2, 3]', wrap_root: false)

      expect(ast).to eq(
        Exps.new(
          [
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
