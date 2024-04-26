require 'spec_helper'

describe StoutLangParser do

  describe "assignment" do
    it 'should parse assignments' do
      ast = Parser.new.parse('a = 10', {wrap_root: false})
      match_ast = Block.new(
        expressions=[
          Assignment.new(
            identifier=Identifier.new(name="a"),
            expression=IntegerLiteral.new(value=10),
            type_sig=nil
          )
        ],
        args=nil
      )
      expect(ast).to eq(match_ast)
    end

    it 'should parse assignments with a type definition' do
      ast = Parser.new.parse('a: Int = 10', {wrap_root: false})
      match_ast = Block.new(
        expressions=[
          Assignment.new(
            identifier=Identifier.new(name="a"),
            expression=IntegerLiteral.new(value=10),
            type_sig=TypeSig.new(type_val=Type.new("Int"))
          )
        ]
      )
      expect(ast).to eq(match_ast)
    end

    it 'should assign the results of a function call' do
      ast = Parser.new.parse("def add(a: Int, b: Int) -> Int { a + b }\n\na = 5 + 10")
      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name=Type.new(name="Root"),
          block=Block.new(
            expressions=[
              Def.new(
                name="add",
                args=[
                  Arg.new(
                    name=Identifier.new(name="a"),
                    type_sig=TypeSig.new(type_val=Type.new(name="Int"))
                  ),
                  Arg.new(
                    name=Identifier.new(name="b"),
                    type_sig=TypeSig.new(type_val=Type.new(name="Int"))
                  )
                ],
                return_type=Type.new(name="Int"),
                block=Block.new(
                  expressions=[
                    FunctionCall.new(
                      name="+",
                      args=[Identifier.new(name="a"), Identifier.new(name="b")]
                    )
                  ]
                )
              ),
              Assignment.new(
                identifier=Identifier.new(name="a"),
                expression=FunctionCall.new(
                  name="+",
                  args=[IntegerLiteral.new(value=5), IntegerLiteral.new(value=10)]
                ),
                type_sig=nil
              )
            ]
          )
        )
      )
    end

    it 'should print an int64' do
      code = "a: Int = 10 ; return(a)"

      ast = Parser.new.parse(code)
      visitor = Visitor.new(ast)

      expect(visitor.run).to eq(10)

      visitor.dispose
    end
  end
end
