require 'spec_helper'

describe StoutLangParser do
  describe "methods" do
    it 'should parse method arguments' do

      ast = Parser.new.parse('(awesome.dude(), cool)', root: 'method_call_args', wrap_root: false)

      match_ast = [FunctionCall.new(name="dude", args=[Identifier.new(name="awesome")]), Identifier.new(name="cool")]
      expect(ast).to eq(match_ast)
    end

    it 'should parse method arguments' do
      ast = Parser.new.parse('awesome.ok', wrap_root: false)
      match_ast = Exps.new([FunctionCall.new(name="ok", args=[Identifier.new(name="awesome")])])

      expect(ast).to eq(match_ast)
    end

    it 'should parse complex method calls' do

      ast = Parser.new.parse('awesome.dude(ok.dokey()).yeppers', root: 'expression', wrap_root: false)

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
      ast = Parser.new.parse('()', root: 'method_call_args', wrap_root: false)

      expect(ast).to eq([])

    end

    it 'should define methods' do
      code = <<-END
      def some_method(arg1, arg2) {
        print()
      }
      END
      ast = Parser.new.parse(code.strip, wrap_root: false)

      expect(ast).to eq(
        Exps.new(
          [
            Def.new(
              name="some_method",
              args=[
                Arg.new(name=Identifier.new(name="arg1"), type_sig=nil),
                Arg.new(name=Identifier.new(name="arg2"), type_sig=nil)
              ],
              return_type=nil,
              body=Exps.new([FunctionCall.new(name="print", args=[])])
            )
          ]
        )
      )
    end

    it 'should assign parent to method' do
      code = "def some_method(arg1, arg2) {\nprint()\n}"
      ast = Parser.new.parse(code.strip, wrap_root: false)

      expect(ast).to eq(
        Exps.new(
          [
            Def.new(
              name="some_method",
              args=[
                Arg.new(name=Identifier.new(name="arg1"), type_sig=nil),
                Arg.new(name=Identifier.new(name="arg2"), type_sig=nil)
              ],
              return_type=nil,
              body=Exps.new([FunctionCall.new(name="print", args=[])])
            )
          ]
        )
      )

      def_node = ast.expressions.first
      expect(def_node.parent).to eq(ast)

      arg1 = def_node.args.first
      expect(arg1.parent).to eq(def_node)

      func_call = def_node.body.expressions.first
      expect(func_call.parent).to eq(def_node.body)

    end

    it 'should let def arguments have types' do
      ast = Parser.new.parse('def some_method(arg1: Int, arg2: Str) { 5 }', wrap_root: false)

      expect(ast).to eq(
        Exps.new(
          [
            Def.new(
              name="some_method",
              args=[
                Arg.new(
                  name=Identifier.new(name="arg1"),
                  type_sig=TypeSig.new(type_val=Type.new(name="Int", args=nil))
                ),
                Arg.new(
                  name=Identifier.new(name="arg2"),
                  type_sig=TypeSig.new(type_val=Type.new(name="Str", args=nil))
                )
              ],
              return_type=nil,
              body=Exps.new([IntegerLiteral.new(value=5)])
            )
          ]
        )
      )
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
        Exps.new(
          [
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

      visitor.dispose

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

      visitor.dispose
    end

    it 'should not parse function calls with >1 args and no parens' do
      expect {
        ast = Parser.new.parse("add_one 5, 5")
      }.to raise_error(StoutLang::ParseError)
    end

    it 'should let you pass a block to a method' do
      code = 'add_one(1) { 5 }'
      ast = Parser.new.parse(code, root: 'function_call_with_args', wrap_root: false)

      expect(ast).to eq(
        FunctionCall.new(
          name="add_one",
          args=[
            IntegerLiteral.new(value=1),
            Block.new(args=nil, body=Exps.new([IntegerLiteral.new(value=5)]))
          ]
        )
      )

      code = '  add_one(1) { 5 }  '
      ast = Parser.new.parse(code)

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name=Type.new(name="Root", args=nil),
          body=Exps.new(
            [
              FunctionCall.new(
                name="add_one",
                args=[
                  IntegerLiteral.new(value=1),
                  Block.new(args=nil, body=Exps.new([IntegerLiteral.new(value=5)]))
                ]
              )
            ]
          )
        )

      )

      code = '5.add { 20 }'
      ast = Parser.new.parse(code)

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name=Type.new(name="Root", args=nil),
          body=Exps.new(
            [
              FunctionCall.new(
                name="add",
                args=[
                  IntegerLiteral.new(value=5),
                  Block.new(args=nil, body=Exps.new([IntegerLiteral.new(value=20)]))
                ]
              )
            ]
          )
        )

      )
    end
  end
end
