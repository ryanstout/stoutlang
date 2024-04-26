require 'spec_helper'

describe StoutLangParser do
  describe "libs" do

    it 'should parse libs' do
      code = <<-END
        lib LibC {
          cfunc puts(s: Str) -> Int
        }
      END

      ast = Parser.new.parse(code, wrap_root: false)

      expect(ast).to eq(
        Block.new(
          expressions=[
            Lib.new(
              name=Type.new(name="LibC"),
              block=Block.new(
                expressions=[
                  CFunc.new(
                    name="puts",
                    args=[
                      Arg.new(
                        name=Identifier.new(name="s"),
                        type_sig=TypeSig.new(type_val=Type.new(name="Str"))
                      )
                    ],
                    varargs_enabled=false,
                    return_type=Type.new(name="Int")
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
  end
end
