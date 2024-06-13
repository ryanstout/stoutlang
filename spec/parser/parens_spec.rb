require 'spec_helper'

describe StoutLangParser do
  describe "parens" do
    it 'should handle parens' do
      ast = Parser.new.parse('(ok.dokey()).cool', wrap_root: false)

      match_ast = Exps.new(
        [
          FunctionCall.new(
            name="cool",
            args=[FunctionCall.new(name="dokey", args=[Identifier.new(name="ok")])]
          )
        ]
      )


      expect(ast).to eq(match_ast)

      ast = Parser.new.parse('((((ok).dokey()))).cool((yes).now(ok2))', wrap_root: false)
      match_ast = Exps.new(
        [
          FunctionCall.new(
            name="cool",
            args=[
              FunctionCall.new(name="dokey", args=[Identifier.new(name="ok")]),
              FunctionCall.new(
                name="now",
                args=[Identifier.new(name="yes"), Identifier.new(name="ok2")]
              )
            ]
          )
        ]
      )
      expect(ast).to eq(match_ast)
    end

    it 'should hanlde unnecessary parens' do
      ast = Parser.new.parse('((ok)).call_something', wrap_root: false)

      match_ast = Exps.new(
        [
          FunctionCall.new(name="call_something", args=[Identifier.new(name="ok")])
        ]
      )
      expect(ast).to eq(match_ast)
    end
  end
end
