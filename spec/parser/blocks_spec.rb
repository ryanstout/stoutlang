require "spec_helper"

describe StoutLangParser do
  describe "blocks" do
    it "should handle methods with block arguments" do
      ast = Parser.new.parse("awesome.dude() { cool }", wrap_root: false)

      match_ast = Exps.new(
        [
          FunctionCall.new(
            name = "dude",
            args = [
              Identifier.new(name = "awesome"),
              Block.new(args = nil, body = Exps.new([Identifier.new(name = "cool")])),
            ]
          ),
        ]
      )
      expect(ast).to eq(match_ast)
    end

    it "should let you call a function with 0 or 1 arg without parens and a block argument" do
      ast = Parser.new.parse("awesome.dude { cool }", wrap_root: false)

      match_ast = Exps.new(
        [
          FunctionCall.new(
            name = "dude",
            args = [
              Identifier.new(name = "awesome"),
              Block.new(args = nil, body = Exps.new([Identifier.new(name = "cool")])),
            ]
          ),
        ]
      )

      expect(ast).to eq(match_ast)

      # TODO: Kind of feels like this should require parens?
      ast = Parser.new.parse("awesome.dude 1 { cool }", wrap_root: false)

      match_ast = Exps.new(
        [
          FunctionCall.new(
            name = "dude",
            args = [
              Identifier.new(name = "awesome"),
              IntegerLiteral.new(value = 1),
              Block.new(args = nil, body = Exps.new([Identifier.new(name = "cool")])),
            ]
          ),
        ]
      )
    end

    it "should replace identifiers that point to a function call with a FunctionCall" do
      code = <<-END
        def one() { 1 }

        one
      END
      ast = Parser.new.parse(code)
      ast.prepare

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name = Type.new(name = "Root"),
          body = Exps.new(
            [
              Def.new(
                name = "one",
                args = [],
                return_type = nil,
                body = Exps.new([IntegerLiteral.new(value = 1)])
              ),
              FunctionCall.new(name = "one", args = []),
            ]
          )
        )
      )
    end

    it "should replace identifiers that resolve to functions in arguments" do
      code = <<-END
        def one() { 1 }
        def two() { 2 }

        one(two)
      END
      ast = Parser.new.parse(code)
      ast.prepare

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name = Type.new(name = "Root"),
          body = Exps.new(
            [
              Def.new(
                name = "one",
                args = [],
                return_type = nil,
                body = Exps.new([IntegerLiteral.new(value = 1)])
              ),
              Def.new(
                name = "two",
                args = [],
                return_type = nil,
                body = Exps.new([IntegerLiteral.new(value = 2)])
              ),
              FunctionCall.new(name = "one", args = [FunctionCall.new(name = "two", args = [])]),
            ]
          )
        )
      )
    end

    # TODO: Add parser support for compile time method calls in type sigs
    # it 'should replace identifiers that resolve to functions in type signatures' do
    #   code = <<-END
    #     def two() { Str }
    #     def one(a: Int | two) { 1 }
    #   END

    #   ast = Parser.new.parse(code)
    #   ast.prepare

    #   expect(ast).to eq(
    #      StoutLang::Ast::Struct.new(
    #       name=Type.new(name="Root"),
    #       block=Block.new(
    #         expressions=[
    #           Def.new(
    #             name="two",
    #             args=[],
    #             return_type=nil,
    #             block=Block.new(expressions=[Type.new(name="Str")], args=nil)
    #           ),
    #           Def.new(
    #             name="one",
    #             args=[
    #               Arg.new(
    #                 name=Identifier.new(name="a"),
    #                 type_sig=TypeSig.new(type_val=Type.new(name="Int") | Type.new(name="two"))
    #               )
    #             ],
    #             return_type=nil,
    #             block=Block.new(expressions=[IntegerLiteral.new(value=1)], args=nil)
    #           )
    #         ],
    #         args=nil
    #       )
    #     )
    #   )
    # end

    it 'should parse the block type in def\'s that yield' do
      code = "Str, Str -> Int, Int"
      ast = Parser.new.parse(code, root: "type_expression", wrap_root: false)

      expect(ast).to eq(
        BlockType.new(
          arg_types = [Type.new(name = "Str"), Type.new(name = "Str")],
          return_type = [Type.new(name = "Int"), Type.new(name = "Int")]
        )
      )

      code = "(Str, Str) -> Int, Int"
      ast = Parser.new.parse(code, root: "type_expression", wrap_root: false)

      expect(ast).to eq(
        BlockType.new(
          arg_types = [Type.new(name = "Str"), Type.new(name = "Str")],
          return_type = [Type.new(name = "Int"), Type.new(name = "Int")]
        )
      )
    end

    it 'should parse type expressions with ,\'s between them on the type_infix_chain rule' do
      code = "Str, Int"
      ast = Parser.new.parse(code, root: "type_infix_chain", wrap_root: false)
      # ast.prepare

      expect(ast).to eq([Type.new(name = "Str"), Type.new(name = "Int")])
    end

    it "should let you override yield" do
      # TODO
    end

    it "should parse block args" do
      code = "arg1, arg2"
      ast = Parser.new.parse(code, wrap_root: false, root: "block_args")

      expect(ast).to eq([
        Arg.new(name = Identifier.new(name = "arg1"), type_sig = nil),
        Arg.new(name = Identifier.new(name = "arg2"), type_sig = nil),
      ])
    end

    it "should parse block arguments" do
      code = <<-END
        call_block(1) |arg1, arg2| {
          %> "hey"
        }
      END
      ast = Parser.new.parse(code)
      # ast.prepare

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name = Type.new(name = "Root", args = nil),
          body = Exps.new(
            [
              FunctionCall.new(
                name = "call_block",
                args = [
                  IntegerLiteral.new(value = 1),
                  Block.new(
                    args = [
                      Arg.new(name = Identifier.new(name = "arg1"), type_sig = nil),
                      Arg.new(name = Identifier.new(name = "arg2"), type_sig = nil),
                    ],
                    body = Exps.new(
                      [
                        FunctionCall.new(name = "%>", args = [StringLiteral.new(value = ["hey"])]),
                      ]
                    )
                  ),
                ]
              ),
            ]
          )
        )

      )
    end

    it "should parse block arguments on a function call with no arguments" do
      code = <<-END
        call_block() |arg1, arg2| {
          %> "hey"
        }
      END
      ast = Parser.new.parse(code)
      # ast.prepare

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name = Type.new(name = "Root", args = nil),
          body = Exps.new(
            [
              FunctionCall.new(
                name = "call_block",
                args = [
                  Block.new(
                    args = [
                      Arg.new(name = Identifier.new(name = "arg1"), type_sig = nil),
                      Arg.new(name = Identifier.new(name = "arg2"), type_sig = nil),
                    ],
                    body = Exps.new(
                      [
                        FunctionCall.new(name = "%>", args = [StringLiteral.new(value = ["hey"])]),
                      ]
                    )
                  ),
                ]
              ),
            ]
          )
        )
      )
    end

    it "should parse block arguments on a function call with no arguments and no parens" do
      code = <<-END
        call_block |arg1, arg2| {
          %> "hey"
        }
      END
      ast = Parser.new.parse(code)
      # ast.prepare

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name = Type.new(name = "Root", args = nil),
          body = Exps.new(
            [
              FunctionCall.new(
                name = "call_block",
                args = [
                  Block.new(
                    args = [
                      Arg.new(name = Identifier.new(name = "arg1"), type_sig = nil),
                      Arg.new(name = Identifier.new(name = "arg2"), type_sig = nil),
                    ],
                    body = Exps.new(
                      [
                        FunctionCall.new(name = "%>", args = [StringLiteral.new(value = ["hey"])]),
                      ]
                    )
                  ),
                ]
              ),
            ]
          )
        )

      )
    end

    it "should call the block when yield is called from the function" do
      code = <<-END
        def call_block(block: Int -> Int) {
          yield
        }

        call_block {
          %> "block called"
        }
      END

      ast = Parser.new.parse(code)
      # ast.prepare

      expect(ast).to eq(
        StoutLang::Ast::Struct.new(
          name = Type.new(name = "Root", args = nil),
          body = Exps.new(
            [
              Def.new(
                name = "call_block",
                args = [
                  Arg.new(
                    name = Identifier.new(name = "block"),
                    type_sig = TypeSig.new(
                      type_val = BlockType.new(
                        arg_types = [Type.new(name = "Int", args = nil)],
                        return_type = Type.new(name = "Int", args = nil)
                      )
                    )
                  ),
                ],
                return_type = nil,
                body = Exps.new([Identifier.new(name = "yield")])
              ),
              FunctionCall.new(
                name = "call_block",
                args = [
                  Block.new(
                    args = nil,
                    body = Exps.new(
                      [
                        FunctionCall.new(
                          name = "%>",
                          args = [StringLiteral.new(value = ["block called"])]
                        ),
                      ]
                    )
                  ),
                ]
              ),
            ]
          )
        )
      )
    end

    it "should be able to pass a block to any argument of a function" do
      code = <<-END
        def some_func(block: Int -> Int, arg2: Int) {
        }

        some_func(|block_arg1: Int| { block_arg1 }, 2)
      END

      ast = Parser.new.parse(code, wrap_root: false)
      expect(ast).to eq(
        Exps.new(
          [
            Def.new(
              name = "some_func",
              args = [
                Arg.new(
                  name = Identifier.new(name = "block"),
                  type_sig = TypeSig.new(
                    type_val = BlockType.new(
                      arg_types = [Type.new(name = "Int", args = nil)],
                      return_type = Type.new(name = "Int", args = nil)
                    )
                  )
                ),
                Arg.new(
                  name = Identifier.new(name = "arg2"),
                  type_sig = TypeSig.new(type_val = Type.new(name = "Int", args = nil))
                ),
              ],
              return_type = nil,
              body = Exps.new([])
            ),
            FunctionCall.new(
              name = "some_func",
              args = [
                Block.new(
                  args = [
                    Arg.new(
                      name = Identifier.new(name = "block_arg1"),
                      type_sig = TypeSig.new(type_val = Type.new(name = "Int", args = nil))
                    ),
                  ],
                  body = Exps.new([Identifier.new(name = "block_arg1")])
                ),
                IntegerLiteral.new(value = 2),
              ]
            ),
          ]
        )
      )
    end

    # Currently Segfaults, something with MCJit
    # it 'should be able to call a block and get the return argument from yield' do
    #   code = <<-END
    #     def combine(a: Int, b: Int, block: (Int, Int) -> Int) {
    #       yield(a, b)
    #     }

    #     result = combine(10, 20) |a: Int, b: Int| {
    #       a + b
    #     }

    #     return result
    #   END

    #   # Run the code
    #   ast = Parser.new.parse(code)
    #   visitor = Visitor.new(ast)

    #   ret_val = visitor.run
    #   expect(ret_val).to eq(30)

    #   visitor.dispose

    # end
  end
end
