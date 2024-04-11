require 'spec_helper'

describe StoutLangParser do
  describe 'strings' do
    it 'should parse strings' do
      ast = Parser.new.parse('"hello"', root: 'string', wrap_root: false)
      match_ast = StringLiteral.new(value=["hello"])


      expect(ast).to eq(match_ast)
    end

    it 'should parse with escaped characters' do
      ast = Parser.new.parse('"hello\nworld"', root: 'string', wrap_root: false)
      match_ast = StringLiteral.new(value=["hello\nworld"])

      expect(ast).to eq(match_ast)
    end

    it 'should handle interpolation' do
      ast = Parser.new.parse('"hello ${world}"', root: 'string', wrap_root: false)

      expect(ast).to eq(
        StringLiteral.new(
          value=[
            "hello ",
            StringInterpolation.new(
              block=Block.new(expressions=[Identifier.new(name="world")])
            )
          ]
        )
      )
    end

    it 'should evaluate interpolations' do
      ast = Parser.new.parse('"hello ${5 + 10}"', root: 'string', wrap_root: false)
      ast.prepare

      expect(ast.run).to eq("hello 15")
    end

    it 'should handle heredocs' do
      ast = Parser.new.parse('"""hello' + "\n" + 'world"""', root: 'string', wrap_root: false)

      expect(ast).to eq(StringLiteral.new(value=["hello\nworld"]))
    end

    it 'should support a heredoc with interpolation' do
      ast = Parser.new.parse('"""hello ${world}' + "\n" + 'world"""', root: 'string', wrap_root: false)

      expect(ast).to eq(
        StringLiteral.new(
          value=[
            "hello ",
            StringInterpolation.new(
              block=Block.new(expressions=[Identifier.new(name="world")])
            ),
            "\nworld"
          ]
        )
      )
    end
  end
end
