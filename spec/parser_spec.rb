require 'spec_helper'
require 'parser/ast/ast_nodes'

include StoutLang::Ast

describe StoutLangParser do

  it 'should parse method arguments' do

    ast = Ast.new.parse('(awesome.dude(), cool)', root: 'method_args')

    match_ast = [FunctionCall.new(name="dude", args=[Identifier.new(name="awesome")]), Identifier.new(name="cool")]
    expect(ast).to eq(match_ast)

  end

  it 'should parse integers' do
    ast = Ast.new.parse('20')
    expect(ast).to eq(Block.new(expressions=[IntegerLiteral.new(value="20")]))
  end

  # it 'should handle infix method calls' do
  #   ast = Ast.new.parse('5 + 10')
  #   match_ast = Block.new([])

  #   expect(ast).to eq(match_ast)
  # end

  it 'should handle parens' do
    ast = Ast.new.parse('(ok.dokey()).cool')

    match_ast = Block.new(
      expressions=[
        FunctionCall.new(
          name="cool",
          args=[FunctionCall.new(name="dokey", args=[Identifier.new(name="ok")])]
        )
      ]
    )

    expect(ast).to eq(match_ast)

    ast = Ast.new.parse('((((ok).dokey()))).cool((yes).now(ok2))')
    match_ast = Block.new(
      expressions=[
        FunctionCall.new(
          name="cool",
          args=[
            FunctionCall.new(name="dokey", args=[Identifier.new(name="ok")]),
            FunctionCall.new(
              name="now",
              args=[Identifier.new(name="yes"), Identifier.new(name="ok2")]
            )
          ]
        )
      ]
    )
    expect(ast).to eq(match_ast)
  end

  it 'should hanlde unnecessary parens' do
    ast = Ast.new.parse('((ok)).call_something')
    match_ast = Block.new(
        expressions=[FunctionCall.new(name="call_something", args=[Identifier.new(name="ok")])]
      )
    expect(ast).to eq(match_ast)
  end

  it 'should parse method arguments' do
    ast = Ast.new.parse('awesome.ok', root: 'expression')

    match_ast = FunctionCall.new(
      name="ok",
      args=[
        Identifier.new(name="awesome")
      ]
    )

    expect(ast).to eq(match_ast)

    ast = Ast.new.parse('awesome.dude(ok.dokey()).yeppers', root: 'expression')
  
    match_ast = FunctionCall.new(
      name="yeppers",
      args=[
        FunctionCall.new(
          name="dude",
          args=[
            Identifier.new(name="awesome"),
            FunctionCall.new(name="dokey", args=[Identifier.new(name="ok")])
          ]
        )
      ]
    )
  end
end