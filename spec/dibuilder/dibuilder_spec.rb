require 'spec_helper'

describe "DIBuilder" do
  it 'should create a module' do
    ast = Parser.new.parse("struct Test { }")

    visitor = Visitor.new(ast)
  end
end
