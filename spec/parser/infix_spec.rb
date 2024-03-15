require 'spec_helper'

describe StoutLangParser do
  describe 'infix operators' do
    it 'should support infix method calls' do
      ast = Ast.new.parse('5 + 10')
      match_ast = Block.new(
          expressions=[
            FunctionCall.new(
              name="+",
              args=[IntegerLiteral.new(value=5), IntegerLiteral.new(value=10)]
            )
          ]
        )

      expect(ast).to eq(match_ast)
    end

    it 'should support a chain of infix operations' do
      ast = Ast.new.parse('5 + (10 + 20) * 30')
      match_ast = Block.new(
          expressions=[
            FunctionCall.new(
              name="+",
              args=[
                IntegerLiteral.new(value=5),
                FunctionCall.new(
                  name="*",
                  args=[
                    FunctionCall.new(
                      name="+",
                      args=[IntegerLiteral.new(value=10), IntegerLiteral.new(value=20)]
                    ),
                    IntegerLiteral.new(value=30)
                  ]
                )
              ]
            )
          ]
        )

      expect(ast).to eq(match_ast)
    end

    it 'should support infix method calls, with parens, and method chains' do
      ast = Ast.new.parse('5 + (10 + 20).dokey().cool')
      match_ast = Block.new(
          expressions=[
            FunctionCall.new(
              name="+",
              args=[
                IntegerLiteral.new(value=5),
                FunctionCall.new(
                  name="cool",
                  args=[
                    FunctionCall.new(
                      name="dokey",
                      args=[
                        FunctionCall.new(
                          name="+",
                          args=[IntegerLiteral.new(value=10), IntegerLiteral.new(value=20)]
                        )
                      ]
                    )
                  ]
                )
              ]
            )
          ]
        )

      expect(ast).to eq(match_ast)
    end

    it 'should follow operator prescedence' do
      ast = Ast.new.parse('5 + 10 * 20')
      match_ast = Block.new(
          expressions=[
            FunctionCall.new(
              name="+",
              args=[
                IntegerLiteral.new(value=5),
                FunctionCall.new(
                  name="*",
                  args=[IntegerLiteral.new(value=10), IntegerLiteral.new(value=20)]
                )
              ]
            )
          ]
        )

      expect(ast).to eq(match_ast)
    end

    it 'should follow operator prescedence with parens' do
      ast = Ast.new.parse('(5 + 10) * 20')
      match_ast = Block.new(
          expressions=[
            FunctionCall.new(
              name="*",
              args=[
                FunctionCall.new(
                  name="+",
                  args=[IntegerLiteral.new(value=5), IntegerLiteral.new(value=10)]
                ),
                IntegerLiteral.new(value=20)
              ]
            )
          ]
        )

      expect(ast).to eq(match_ast)
    end
  end

end
