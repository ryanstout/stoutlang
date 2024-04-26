require 'spec_helper'

describe CFunc do
  it 'should register a cfunc' do
    ast = Parser.new.parse("cfunc sleep(i: Int) -> Int")

    visitor = Visitor.new(ast)

    expect(visitor.root_mod.functions.named('sleep').to_s).to eq("declare i32 @sleep(i32)\n")
  end
end
