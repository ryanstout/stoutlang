require 'spec_helper'
require 'codegen/name_mangle'

describe NameMangle do
  it 'should mangle and unmangle a def' do
    int_type = Type.new('Int')
    def_node = Def.new('hello2', [Arg.new('a', type_sig=TypeSig.new(type_val=int_type))], int_type, nil)

    mangled = def_node.mangled_name
    expect(mangled).to eq('sl1.hello2(Int)->Int')

    unmangled = Import.new.unmangle(mangled)
    expect(unmangled).to eq(['hello2', ['Int'], 'Int'])
  end
end
