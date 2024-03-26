require 'spec_helper'

describe StoutLangParser do
  it 'should match a type' do
    ast = Ast.new.parse('Int', root: 'type_expression')

    expect(ast).to eq(Type.new(name="Int"))

  end
  it 'should parse a type variable' do
    ast = Ast.new.parse('\'tv', root: 'type_primary')

    expect(ast).to eq(TypeVariable.new(name="tv"))
  end

  it 'should support infix operators in type signatures' do
    ast = Ast.new.parse('Str | Int', root: 'type_expression')

    expect(ast).to eq(FunctionCall.new(
      name="|",
      args=[
        Type.new(name="Str"),
        Type.new(name="Int")
      ]
    ))
  end
end
