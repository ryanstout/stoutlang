
- method calls on self without the self
- html syntax inline
- figure out how to reorder logs so they come out in the right order
- properties should raise during compile if they are not in a struct
- Move creation of assignments to the infix operators
- What should assignment do inside of a list  [a = 5, b = 10]
- Assignment inside of StringLiterals?
- Infix operators should be able to be run with parens like: *(5, 10) or %>("Hello World")
- article on how effects can rerun production code to do profiled ai optimization
- Demo of how hard stack traces are in rust
- Maybe Any types show up in yellow in LSP?
- Phi node for returning values from if blocks
- mention how crazy this article is: https://jondot.medium.com/errors-in-rust-a-formula-1e3e9a37d207
- thunked string interpolation that can write parts straight to buffers
- Auto getter/setters?
- the burned once never again cycle  - baby with the bath water
- Write an article on how functional is better but not with regards to ergonomics
- Marketing: why do different people prefer different languages, because different features are better for different tasks.
- add a nomangle flag so functions can be exposed with C callable names
- def's should be able to have the same name for arguments
- should CPrototypes be matched based on arguments in lookup_function
- a block should not be able to be passed to a function with 1 argument without parens (gets confusing imho, see this doc: https://crystal-lang.org/reference/1.12/syntax_and_semantics/blocks_and_procs.html#blocks-and-procs)
- should we warn/error if the code redefines the same function in the same scope? (same args/block)
- numerical upcasting (so lookup_function will work if the type is larger and there isn't one with a closer type)


Todays:
+ identifiers should get converted to function calls in prepare
+ metadata writing
+ c bindings (ExternFunction and CFunction should inherit from Def?)
    - need ability to specify import path, flags, etc..
    - need ability to specify the function name in stoutlang and the C version (LLVM... - starts with capital)
    - c func names can be any string in llvm, add string named cfuncs
+ name mangling
+ method dispatching based on types
- #type should probably be #evaluated_type (for function types to make sense)
- feels like prepare and identifier evaluation needs a bit of a rework. Should identfiier lookup happen in prepare and be cached?
- ability to return types
- method matching based on instance of a type (essentially static dispatch):
    ```
    struct Color {
      def red(_: ^Color) { '#FF0000'}
    }
    ```

    needs some syntax to say we're matching to this specific type (and subtypes), but not an instance of it.

    One issue with ^ is that it't hard to catch. I like the idea of keeping the way dispatch works general. (only one type of dispatch)
- blocks
  - blocks should have take a Union of each possible type they are called with

- properties, methods, substructs, etc.. should not be allowed on lib's. cfunc's should not be allowed on structs
- cfuncs need to set attributes (no_capture, etc..) on arguments
- function arguments should use the name in the IR


Saturday:
-- prepare needs to register all functions
  - but we need to register assignments in codegen, so we can't lookup a value before its created
  - Probably the easiest way to do this is to have Identifier forward calls to the thing it identifies and we don't have a replacement step
  - add specs to check that we can't reference assignments before they show up
-- instead of having BaseType and registering those, the registered primitive types should be instances of Type (the AST node) and maybe take an argument for what they codegen to. We need to be able to == compare and Type.new("Int") should be the same as Type.new("Int", codegen_to: LLVM::Int)


- mention example of how a better language lets you keep more in your head, which is like cache levels. If you're oun the boundary, a 10% more memory use can push things out of L1, resulting in a 100x slowdown -- mention 20k line of code studieso

- Why do I have to start a debugger session, could we build a stack frame parser that lets you jump into debugging at any point? (from a dev mode at least) and have a time traveling debugger


- [Arg.new('path', TypeSig.new(type_val=Type.new('Str', self), self), self)] <- should assign parent chain correctly

- add support for Any type in properties (ivars)
- should identifiers not allow capital letters at all?

- it should raise if you double define a def in the same scope (with the same args)

- Stoutlang: maybe you should be able to do () on a value (all values can be treated like functions, so you can swap them for functions later)
- Handle malloc's failing (returning null)

### add a resolve_identifiers step that replaces identifiers with the resolved nodes

- run after prepare, before codegen
- LocalVar, InstanceVar, FunctionCall
- should Type's be resolved? Parametric types create new types
  - Types will need to be parameterized. How would literal types and generic structs be represented?
  - When will type expressions get evaluated, do we need a recursive evaluation process?
  - We probably want a way to store the original AstNodes as we replace them, and a way to pass on the start/end character positions from the source
  - Maybe a walker class that handles the replacement and re-evaluation
  - Def's and properties need to register first, but assignment needs to register when evaluated
  
  --- blocks need a scope when passed (call them a BlockArg maybe?)

  - We need an Exp's ("list of expressions") type that Block and Def both include (or inherit from?)
    - if's need Exps (or argument-less blocks)


  Maybe funcs/def's should look like (use block syntax), that way | and | is always to create a callable, and ( and ) are always to call it. (Makes more sense, but less conventional):

  ```
  combine = |a: Int, b: Int, block: Int -> Int| -> Int {

  }


  ## Need to add a triple target even when not cross compiling, LLVM won't enable more specific optimizations without it. https://llvm.org/docs/Frontend/PerformanceTips.html