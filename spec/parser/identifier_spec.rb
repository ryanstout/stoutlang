require 'spec_helper'

describe StoutLangParser do
  describe "identifiers" do

    it 'should resolve an identifier to a function argument during prepare' do
      code = <<-END
      def get_hey() { "hey" }
      def say_hi(greeting: Str) { %> greeting }

      get_hey.say_hi()

      END
      ast = Parser.new.parse(code)
      expect(ast.body.expressions[2].args[0]).to eq(Identifier.new(name="get_hey"))

      ast.prepare
      expect(ast.body.expressions[2].args[0]).to eq(FunctionCall.new(name="get_hey", args=[]))
    end
  end
end
