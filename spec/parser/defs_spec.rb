require 'spec_helper'

describe StoutLangParser do
  describe "defs" do
    it 'should assign arguments to the scope' do
      ast = Parser.new.parse("struct Test {\n def say_hi(name: Str) {  } \n }")

      def_node = ast.block.expressions[0].block.expressions[0]

      def_node.prepare
    end

    it 'should let you define a method for an operator' do
      ast = Parser.new.parse("struct Int {\n def +(other: Int) {  } \n }")

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name=Type.new("Root"),
          block=Block.new(
            expressions=[
              StoutLang::Ast::Struct.new(
                name=Type.new(name="Int"),
                block=Block.new(
                  expressions=[
                    Def.new(
                      name="+",
                      args=[
                        DefArg.new(
                          name=Identifier.new(name="other"),
                          type_sig=TypeSig.new(type_val=Type.new(name="Int"))
                        )
                      ],
                      return_type=nil,
                      block=Block.new(expressions=[])
                    )
                  ]
                )
              )
            ]
          )
        )
      )
    end

    it 'should allow -> to define the return type' do
      ast = Parser.new.parse("def say_hi(name: Str) -> Int { 5 }")

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name=Type.new("Root"),
          block=Block.new(
            expressions=[
              Def.new(
                name="say_hi",
                args=[
                  DefArg.new(
                    name=Identifier.new(name="name"),
                    type_sig=TypeSig.new(type_val=Type.new(name="Str"))
                  )
                ],
                return_type=Type.new(name="Int"),
                block=Block.new(expressions=[IntegerLiteral.new(value=5)])
              )
            ]
          )
        )
      )
    end


    it 'should codegen functions' do
      ast = Parser.new.parse("def ret_5(num: Int) -> Int { 5 }")

      visitor = Visitor.new(ast)

    end

    it 'should use argumnt types' do
      ast = Parser.new.parse("def add_one(val: Int) -> Int { 1 }")

      visitor = Visitor.new(ast)

    end

    it 'should let you call a function with 0 or 1 arg without parens' do
      ast = Parser.new.parse("add_one 5", root: 'method_chain', wrap_root: false)

      expect(ast).to eq(
        FunctionCall.new(name="add_one", args=[IntegerLiteral.new(value=5)])
      )

      # When we have a method call with zero args, we have to parse it as an identifier, then
      # during codegen we can look up the identifier and see if it's a function call or a local
      ast = Parser.new.parse("c = zero_args ; 5", wrap_root: false)
      expect(ast).to eq(
        Block.new(
          expressions=[
            Assignment.new(
              identifier=Identifier.new(name="c"),
              expression=Identifier.new(name="zero_args"),
              type_sig=nil
            ),
            IntegerLiteral.new(value=5)
          ]
        )
      )
    end

    it 'should be able to call a zero arg function in an assignemnt' do
      code = <<-END
      def return_ten() -> Int {
        10
      }

      c = return_ten
      return(c)
      END
      ast = Parser.new.parse(code)

      visitor = Visitor.new(ast)
      ret_val = visitor.run

      expect(ret_val).to eq(10)

    end

    it 'should be able to call a 1 arg function' do
      code = <<-END
      def return_arg(arg: Int) -> Int {
        arg
      }

      c = return_arg 5
      return(c)
      END
      ast = Parser.new.parse(code)

      visitor = Visitor.new(ast)
      ret_val = visitor.run

      expect(ret_val).to eq(5)
    end

    it 'should not parse function calls with >1 args and no parens' do
      expect {
        ast = Parser.new.parse("add_one 5, 5")
      }.to raise_error(StoutLang::ParseError)
    end
  end
end
