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

    it 'should use argumnt types' do
      ast = Parser.new.parse("def add_one(val: Int) -> Int { 1 }")

      visitor = Visitor.new(ast)

    end
  end
end
