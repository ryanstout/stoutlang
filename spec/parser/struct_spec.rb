require 'spec_helper'

describe StoutLangParser do
  describe "structs" do
    it 'should parse a struct' do
      ast = Parser.new.parse("struct Person {\n  5\n}", root: 'struct', wrap_root: false)

      expect(ast).to eq(StoutLang::Ast::Struct.new(
          name=Type.new(name="Person"),
          block=Block.new(expressions=[IntegerLiteral.new(value=5)])
        ))
    end

    it 'should parse a struct, then an expression' do
      ast = Parser.new.parse("struct Person {\n  5\n}\n10", wrap_root: false)

      expect(ast).to eq(Block.new(
        expressions=[
          StoutLang::Ast::Struct.new(
            name=Type.new(name="Person"),
            block=Block.new(expressions=[IntegerLiteral.new(value=5)])
          ),
          IntegerLiteral.new(value=10)
        ]
      ))
    end

    it 'should parse defs in structs' do
      ast = Parser.new.parse("struct Ok { \n def initialize(name: Str) { \n5\n } \n }")
      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name=Type.new("Root"),
          block=Block.new(
            expressions=[
              StoutLang::Ast::Struct.new(
                name=Type.new(name="Ok"),
                block=Block.new(
                  expressions=[
                    Def.new(
                      name="initialize",
                      args=[
                        DefArg.new(
                          name=Identifier.new(name="name"),
                          type_sig=TypeSig.new(type_val=Type.new(name="Str"))
                        )
                      ],
                      return_type=nil,
                      block=Block.new(expressions=[IntegerLiteral.new(value=5)])
                    )
                  ]
                )
              )
            ]
          )
        )
      )
    end

    it 'should codegen the properties into a llvm struct' do
      # code = <<-END
      # struct Person {
      #   @age: Int

      #   # def init(self, age: Int) {
      #   #   %> "Init"
      #   # }
      #   #
      #   %> i32_size.to_s_i64()
      # }

      # END
      # ast = Parser.new.parse(code)

      # visitor = Visitor.new(ast)
      # mod = visitor.root_mod

      # struct = mod.structs['Person']
      # expect(struct).to be_a(LLVM::Type)
      # expect(struct.name).to eq('Person')
      # expect(struct.elements.size).to eq(2)
      # expect(struct.elements[0]).to eq(LLVM::Type.pointer(LLVM::Type::Int8))
      # expect(struct.elements[1]).to eq(LLVM::Type::Int32)
    end
  end
end
