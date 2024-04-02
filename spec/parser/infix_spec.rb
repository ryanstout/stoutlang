require 'spec_helper'

describe StoutLangParser do
  describe 'infix operators' do
    it 'should support infix method calls' do
      ast = Parser.new.parse('5 + 10', wrap_root: false)
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

    it 'should call with ruby style precedence' do
      ast = Parser.new.parse('20 * 10 / 5', root: "infix_chain", wrap_root: false)

      expect(ast).to eq(
        FunctionCall.new(
          name="/",
          args=[
            FunctionCall.new(
              name="*",
              args=[IntegerLiteral.new(value=20), IntegerLiteral.new(value=10)]
            ),
            IntegerLiteral.new(value=5)
          ]
        )
      )
    end

    it 'should do add and mul with the right precidence' do
      ast = Parser.new.parse('20 * 5 / 4 + 2', wrap_root: false)

      expect(ast).to eq(
        Block.new(
          expressions=[
            FunctionCall.new(
              name="+",
              args=[
                FunctionCall.new(
                  name="/",
                  args=[
                    FunctionCall.new(
                      name="*",
                      args=[IntegerLiteral.new(value=20), IntegerLiteral.new(value=5)]
                    ),
                    IntegerLiteral.new(value=4)
                  ]
                ),
                IntegerLiteral.new(value=2)
              ]
            )
          ]
        )
      )

    end

    it 'should do add and sub with the right precidence' do
      ast = Parser.new.parse('5 + 2 - 4', wrap_root: false)

      expect(ast).to eq(
        Block.new(
          expressions=[
            FunctionCall.new(
              name="-",
              args=[
                FunctionCall.new(
                  name="+",
                  args=[IntegerLiteral.new(value=5), IntegerLiteral.new(value=2)]
                ),
                IntegerLiteral.new(value=4)
              ]
            )
          ]
        )
      )

    end


    it 'should support a chain of infix operations' do
      ast = Parser.new.parse('5 + (10 + 20) * 30', wrap_root: false)
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
      ast = Parser.new.parse('5 + (10 + 20).dokey().cool', wrap_root: false)
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
      ast = Parser.new.parse('5 + 10 * 20', wrap_root: false)
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
      ast = Parser.new.parse('(5 + 10) * 20', wrap_root: false)
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
