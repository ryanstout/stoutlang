require 'spec_helper'

describe StoutLangParser do
  describe "methods" do
    it 'should parse method arguments' do

      ast = Parser.new.parse('(awesome.dude(), cool)', root: 'method_call_args')

      match_ast = [FunctionCall.new(name="dude", args=[Identifier.new(name="awesome")]), Identifier.new(name="cool")]
      expect(ast).to eq(match_ast)
    end

    it 'should handle methods with block arguments' do
      ast = Parser.new.parse('awesome.dude() { cool }')

      match_ast = Block.new(
          expressions=[
            FunctionCall.new(
              name="dude",
              args=[
                Identifier.new(name="awesome"),
                Block.new(expressions=[Identifier.new(name="cool")])
              ]
            )
          ]
        )
      expect(ast).to eq(match_ast)
    end

    it 'should parse method arguments' do
      ast = Parser.new.parse('awesome.ok')

      match_ast = Block.new(
        expressions=[
          FunctionCall.new(name="ok", args=[
            Identifier.new(name="awesome")
          ]
        )]
      )

      expect(ast).to eq(match_ast)
    end

    it 'should parse complex method calls' do

      ast = Parser.new.parse('awesome.dude(ok.dokey()).yeppers', root: 'expression')

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

    it 'should handle empty method args' do
      ast = Parser.new.parse('()', root: 'method_call_args')

      expect(ast).to eq([])

    end

    it 'should define methods' do
      code = <<-END
      def some_method(arg1, arg2) {
        print()
      }
      END
      ast = Parser.new.parse(code.strip)

      expect(ast).to eq(
        Block.new(
          expressions=[
            Def.new(
              name="some_method",
              args=[
                DefArg.new(name=Identifier.new(name="arg1"), type_sig=nil),
                DefArg.new(name=Identifier.new(name="arg2"), type_sig=nil)
              ],
              block=Block.new(expressions=[FunctionCall.new(name="print", args=[])])
            )
          ]
        )
      )
    end

    it 'should assign parent to method' do
      code = <<-END
      def some_method(arg1, arg2) {
        print()
      }
      END
      ast = Parser.new.parse(code.strip)

      expect(ast).to eq(
        Block.new(
          expressions=[
            Def.new(
              name="some_method",
              args=[
                DefArg.new(name=Identifier.new(name="arg1"), type_sig=nil),
                DefArg.new(name=Identifier.new(name="arg2"), type_sig=nil)
              ],
              block=Block.new(expressions=[FunctionCall.new(name="print", args=[])])
            )
          ]
        )
      )

      def_node = ast.expressions.first
      expect(def_node.parent).to eq(ast)

      arg1 = def_node.args.first
      expect(arg1.parent).to eq(def_node)

      func_call = def_node.block.expressions.first
      expect(func_call.parent).to eq(def_node.block)

    end

    it 'should let def arguments have types' do
      ast = Parser.new.parse('def some_method(arg1: Int, arg2: Str) { 5 }')

      expect(ast).to eq(
        Block.new(
          expressions=[
            Def.new(
              name="some_method",
              args=[
                DefArg.new(name=Identifier.new(name="arg1"), type_sig=nil),
                DefArg.new(name=Identifier.new(name="arg2"), type_sig=nil)
              ],
              block=Block.new(expressions=[IntegerLiteral.new(value=5)])
            )
          ]
        )
      )
    end
  end
end
