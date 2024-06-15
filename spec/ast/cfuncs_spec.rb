require "spec_helper"

describe CFunc do
  it "should register a cfunc" do
    code = <<-END
      lib LibC {
        cfunc sleep(i: Int) -> Int
      }
    END
    ast = Parser.new.parse(code)

    visitor = Visitor.new(ast)

    expect(visitor.root_mod.functions.named("sleep").to_s).to eq("declare available_externally i32 @sleep(i32)\n")
    visitor.dispose
  end
end
