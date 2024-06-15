require "spec_helper"
require "codegen/name_mangle"

describe NameMangle do
  class TestNameMangle
    include StoutLang::NameMangle
  end

  it "should mangle and unmangle a def" do
    int_type = Type.new("Int")
    def_node = Def.new("hello2", [Arg.new("a", type_sig = TypeSig.new(type_val = int_type))], int_type, nil)

    mangled = def_node.mangled_name
    expect(mangled).to eq("sl1.hello2(Int)->Int")

    unmangled = Import.new.unmangle(mangled)
    expect(unmangled).to eq(
      { :sl_version => "1", :func_name => "hello2", :arg_types => [Arg.new(
        name = "_",
        type_sig = TypeSig.new(type_val = Type.new(name = "Int", args = nil))
      )], :return_type => Type.new(name = "Int", args = nil) }
    )
  end

  it "should be able to unmangle names with block types" do
    name = "sl1.times(Int,(Int,Int)->Int)->Int"

    result = TestNameMangle.new.unmangle(name)

    expect(result).to eq(
      { :sl_version => "1", :func_name => "times", :arg_types => [Arg.new(name = "_", type_sig = TypeSig.new(type_val = Type.new(name = "Int", args = nil))), Arg.new(
        name = "_",
        type_sig = TypeSig.new(
          type_val = BlockType.new(
            arg_types = [Type.new(name = "Int", args = nil), Type.new(name = "Int", args = nil)],
            return_type = Type.new(name = "Int", args = nil)
          )
        )
      )], :return_type => Type.new(name = "Int", args = nil) }
    )
  end

  it "should be able to parse mangled operator names" do
    name = "sl1.%>(Str)->Str"

    result = TestNameMangle.new.unmangle(name)

    expect(result).to eq(
      { :sl_version => "1", :func_name => "%>", :arg_types => [Arg.new(
        name = "_",
        type_sig = TypeSig.new(type_val = Type.new(name = "Str", args = nil))
      )], :return_type => Type.new(name = "Str", args = nil) }
    )
  end
end
