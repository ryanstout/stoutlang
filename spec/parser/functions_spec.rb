require 'spec_helper'

describe StoutLangParser do
  describe "functions" do
    it 'should parse function calls' do
      ast = Parser.new.parse('print()', root: 'function_call_with_args', wrap_root: false)

      expect(ast).to eq(FunctionCall.new(name="print", args=[]))
    end

    it 'should parse function call with arguments' do
      ast = Parser.new.parse('print(1, 2)', root: 'function_call_with_args', wrap_root: false)

      expect(ast).to eq(FunctionCall.new(name="print", args=[IntegerLiteral.new(value=1), IntegerLiteral.new(value=2)]))
    end

    it 'should allow function calls from the root' do
      ast = Parser.new.parse('print()', wrap_root: false)
      expect(ast).to eq(Block.new(expressions=[FunctionCall.new(name="print", args=[])]))

    end

    it 'should parse functions after some method calls' do
      ast = Parser.new.parse("a = 5\n5.name()\nprint(\"Hello\").to_i()", wrap_root: false)

      expect(ast).to eq(
        Block.new(
          expressions=[
            Assignment.new(
              identifier=Identifier.new(name="a"),
              expression=IntegerLiteral.new(value=5),
              type_sig=nil
            ),
            FunctionCall.new(name="name", args=[IntegerLiteral.new(value=5)]),
            FunctionCall.new(
              name="to_i",
              args=[
                FunctionCall.new(name="print", args=[StringLiteral.new(value=["Hello"])])
              ]
            )
          ]
        )
      )
    end

    it 'should dispatch based on argument types (function overloading)' do
      code = <<-END
      def return_type_name(val: Int) -> Str {
        "Int"
      }

      def return_type_name(val: Str) -> Str {
        "Str"
      }

      def check() -> Str {
        return_type_name(5)
      }
      END

      ast = Parser.new.parse(code)
      visitor = Visitor.new(ast)

      ret = visitor.run_function('check', [], 'Str')

      expect(ret.to_value_ptr.read_string).to eq("Int")
    end

    it 'should handle resolution of function calls with mutliple args' do
      code = <<-END
      def ret_val(a: Int, b: Int) -> Int {
        1
      }

      def ret_val(a: Int, b: Str) -> Int {
        2
      }

      def ret_val(a: Str, b: Str) -> Int {
        3
      }

      def check1() -> Int {
        ret_val(1,1)
      }

      def check2() -> Int {
        ret_val(1,"1")
      }

      def check3() -> Int {
        ret_val("1","1")
      }
      END

      ast = Parser.new.parse(code)
      visitor = Visitor.new(ast)

      ret = visitor.run_function('check1', [], 'Int')
      expect(ret.to_i).to eq(1)

      ret = visitor.run_function('check2', [], 'Int')
      expect(ret.to_i).to eq(2)

      ret = visitor.run_function('check3', [], 'Int')
      expect(ret.to_i).to eq(3)
    end
  end
end
