
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


Todays:
+ identifiers should get converted to function calls in prepare
+ metadata writing
+ c bindings (ExternFunction and CFunction should inherit from Def?)
    - need ability to specify import path, flags, etc..
    - need ability to specify the function name in stoutlang and the C version (LLVM... - starts with capital)
    - c func names can be any string in llvm, add string named cfuncs
+ name mangling
- method dispatching based on types
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

- properties, methods, substructs, etc.. should not be allowed on lib's. cfunc's should not be allowed on structs
- cfuncs need to set attributes (no_capture, etc..) on arguments
- function arguments should use the name in the IR