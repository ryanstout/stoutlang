require 'spec_helper'

describe StoutLangParser do
  describe "defs" do
    it 'should assign arguments to the scope' do
      ast = Parser.new.parse("struct Test {\n def say_hi(name: Str) {  } \n }")

      def_node = ast.block.expressions[0].block.expressions[0]

      def_node.prepare
    end
  end
end
