require 'spec_helper'

describe StoutLangParser do
  describe "ifs" do
    it 'should parse a simple if' do
      ast = Parser.new.parse('if true { 10 }', root: 'if_expression', wrap_root: false)

      expect(ast).to eq(
        If.new(
          condition=TrueLiteral.new(),
          if_body=Exps.new([IntegerLiteral.new(value=10)]),
          elifs_bodys=[],
          else_body=nil
        )
      )
    end

    it 'should parse if with else over multiple lines' do
      ast = Parser.new.parse("if true\n{ 10 }\nelse\n{ 20 }", wrap_root: false)

      expect(ast).to eq(
        Exps.new(
          [
            If.new(
              condition=TrueLiteral.new(),
              if_body=Exps.new([IntegerLiteral.new(value=10)]),
              elifs_bodys=[],
              else_body=ElseClause.new(body=Exps.new([IntegerLiteral.new(value=20)]))
            )
          ]
        )
      )
    end

    it 'should parse more complex if/elif/else' do
      ast = Parser.new.parse('if true { 10 } elif false { 20 } else { 30 }', wrap_root: false)

      expect(ast).to eq(
        Exps.new(
          [
            If.new(
              condition=TrueLiteral.new(),
              if_body=Exps.new([IntegerLiteral.new(value=10)]),
              elifs_bodys=[
                ElifClause.new(
                  condition=FalseLiteral.new(),
                  body=Exps.new([IntegerLiteral.new(value=20)])
                )
              ],
              else_body=ElseClause.new(body=Exps.new([IntegerLiteral.new(value=30)]))
            )
          ]
        )
      )
    end

    it 'should allow comments after the condition' do
      ast = Parser.new.parse("if true # a comment\n{ 10 }", wrap_root: false)

      expect(ast).to eq(
        Exps.new(
          [
            If.new(
              condition=TrueLiteral.new(),
              if_body=Exps.new([IntegerLiteral.new(value=10)]),
              elifs_bodys=[],
              else_body=nil
            )
          ]
        )
      )
    end
  end
end
