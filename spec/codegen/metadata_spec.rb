require 'spec_helper'
require 'codegen/metadata'

describe "metadata" do
  it 'should add metadata to a module' do
    mod = LLVM::Module.new('metadata')

    StoutLang::Metadata.add(mod, 'foo', 'bar')

    expect(StoutLang::Metadata.read(mod, 'foo')).to eq(['bar'])

    # Add two metadata strings
    StoutLang::Metadata.add(mod, 'foo', 'baz')

    # Check both are there
    expect(StoutLang::Metadata.read(mod, 'foo')).to eq(['bar', 'baz'])
  end

end
