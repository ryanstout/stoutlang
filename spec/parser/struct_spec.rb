require 'spec_helper'

describe StoutLangParser do
  describe "structs" do
    it 'should parse a struct' do
      ast = Parser.new.parse("struct Person {\n  5\n}", root: 'struct', wrap_root: false)

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name=Type.new(name="Person", args=nil),
          body=Exps.new([IntegerLiteral.new(value=5)])
        )
      )
    end

    it 'should parse a struct, then an expression' do
      ast = Parser.new.parse("struct Person {\n  5\n}\n10", wrap_root: false)

      expect(ast).to eq(
        Exps.new(
          [
            StoutLang::Ast::Struct.new(
              name=Type.new(name="Person", args=nil),
              body=Exps.new([IntegerLiteral.new(value=5)])
            ),
            IntegerLiteral.new(value=10)
          ]
        )
      )
    end

    it 'should parse defs in structs' do
      ast = Parser.new.parse("struct Ok { \n def initialize(name: Str) { \n5\n } \n }")

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name=Type.new(name="Root", args=nil),
          body=Exps.new(
            [
              StoutLang::Ast::Struct.new(
                name=Type.new(name="Ok", args=nil),
                body=Exps.new(
                  [
                    Def.new(
                      name="initialize",
                      args=[
                        Arg.new(
                          name=Identifier.new(name="name"),
                          type_sig=TypeSig.new(type_val=Type.new(name="Str", args=nil))
                        )
                      ],
                      return_type=nil,
                      body=Exps.new([IntegerLiteral.new(value=5)])
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
      code = <<-END
      struct Person {
        @age: Int

        # def init(age: Int) -> Int {
        #   %> "Init"
        # }
        #
        # %> i32_size.to_s()
      }

      END
      ast = Parser.new.parse(code)

      visitor = Visitor.new(ast)
      mod = visitor.root_mod

      visitor.dispose

    end

    it 'should pass in an allocated struct instance when we call new' do
      code = <<-END
        struct Point {
          @x: Int
          @y: Int

          def new(@: Point) {
            return @
          }
        }

        point = Point.new()
      END

      ast = Parser.new.parse(code, wrap_root: false)

      expect(ast).to eq(
        Exps.new(
          [
            StoutLang::Ast::Struct.new(
              name=Type.new(name="Point", args=nil),
              body=Exps.new(
                [
                  Property.new(
                    name=Identifier.new(name="x"),
                    type_sig=TypeSig.new(type_val=Type.new(name="Int", args=nil))
                  ),
                  Property.new(
                    name=Identifier.new(name="y"),
                    type_sig=TypeSig.new(type_val=Type.new(name="Int", args=nil))
                  ),
                  Def.new(
                    name="new",
                    args=[
                      Arg.new(
                        name=Identifier.new(name="@"),
                        type_sig=TypeSig.new(type_val=Type.new(name="Point", args=nil))
                      )
                    ],
                    return_type=nil,
                    body=Exps.new(
                      [
                        FunctionCall.new(name="return", args=[Identifier.new(name="@")])
                      ]
                    )
                  )
                ]
              )
            ),
            Assignment.new(
              identifier=Identifier.new(name="point"),
              expression=FunctionCall.new(name="new", args=[Type.new(name="Point", args=nil)]),
              type_sig=nil
            )
          ]
        )
      )

    end

    it 'should let you get the size of the struct' do
      code = <<-END
        struct Point {
          @x: Int
          @y: Int
        }

        point = Point.new(0, 0)

        return(point.i32_size)
      END

      ast = Parser.new.parse(code)

      visitor = Visitor.new(ast)
      ret_val = visitor.run

      expect(ret_val).to eq(8)

      visitor.dispose

    end

    it 'should auto-create a new method' do

    end

    it 'should assign properties inside of methods' do
      code = <<-END
        struct Point {
          @x: Int
          @y: Int
        }

        def set_x(@: Point, x: Int) {
          @x = x
        }
      END
    end
  end
end
