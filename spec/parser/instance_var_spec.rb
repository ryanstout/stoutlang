require 'spec_helper'

describe StoutLangParser do
  describe "instance variables" do
    it 'should parse instance variables' do

      code = <<-END
        def test_ivar() {
          %> @name
        }
      END
      ast = Parser.new.parse(code, wrap_root: false)

      expect(ast).to eq(
        Exps.new(
          [
            Def.new(
              name="test_ivar",
              args=[],
              return_type=nil,
              body=Exps.new(
                [FunctionCall.new(name="%>", args=[Identifier.new(name="@name")])]
              )
            )
          ]
        )
      )
    end

    it 'should be able to look up instance variables' do
      code = <<-END
        struct Point {
          @x: Int
          @y: Int
        }
        def new(@: Point) {
          return @
        }

        def print_x(@: Point) {
          %> @x.to_s
        }

        point = Point.new()
        point.print_x()
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
                  )
                ]
              )
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
                [FunctionCall.new(name="return", args=[Identifier.new(name="@")])]
              )
            ),
            Def.new(
              name="print_x",
              args=[
                Arg.new(
                  name=Identifier.new(name="@"),
                  type_sig=TypeSig.new(type_val=Type.new(name="Point", args=nil))
                )
              ],
              return_type=nil,
              body=Exps.new(
                [
                  FunctionCall.new(
                    name="%>",
                    args=[
                      FunctionCall.new(name="to_s", args=[Identifier.new(name="@x")])
                    ]
                  )
                ]
              )
            ),
            Assignment.new(
              identifier=Identifier.new(name="point"),
              expression=FunctionCall.new(name="new", args=[Type.new(name="Point", args=nil)]),
              type_sig=nil
            ),
            FunctionCall.new(name="print_x", args=[Identifier.new(name="point")])
          ]
        )
      )
    end
  end
end
