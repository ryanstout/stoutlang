require "spec_helper"

describe "inspect small" do
  it 'should have a way to generate a small representation of types, def\s, and blocks' do
    code = "def hello(name: Str) -> Int {}"
    ast = Parser.new.parse(code, wrap_root: false)
    def_node = ast.expressions[0]

    expect(def_node.inspect_small).to eq("hello(Str) -> Int")

    code = "def hello(name: Str, block: Int -> Int) {}"
    ast = Parser.new.parse(code, wrap_root: false)
    def_node = ast.expressions[0]

    puts def_node.inspect_small
    expect(def_node.inspect_small).to eq("hello(Str, (Int)->Int) -> NilType")
  end
end
