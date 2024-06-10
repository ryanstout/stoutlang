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
        Block.new(
          expressions=[
            Def.new(
              name="test_ivar",
              args=[],
              return_type=nil,
              block=Block.new(
                expressions=[
                  FunctionCall.new(
                    name="%>",
                    args=[InstanceVar.new(name="name")]
                  )
                ],
                args=nil
              )
            )
          ],
          args=nil
        )
      )
    end

    it 'should be able to look up instance variables' do
      code = <<-END
        stuct Point {
          @x: Int
          @y: Int
        }
        def new(self: Point) {
          return self
        }

        def print_x(self: Point) {
          %> @x.to_s
        }

        point = Point.new()
        point.print_x()
      END
      ast = Parser.new.parse(code, wrap_root: false)

      expect(ast.block.expressions[0].block.expressions[0].args[0].name).to eq("name")
    end
  end
end
