# Why a new language?

We're entering a new age of software development. Several large changes will drive the adoption of new languages.

## AI

We can expect that the *majority* of code going forward will be written by AI. While I don't expect AI to full replace developers in the short term, AI generated code will change the priorities with regards to languages and specifically safety guarantees.

AI will significantly reduce the cost to write code, which will drive a greater emphases on the cost of running the code. Languages that are able to run code faster (while keeping the code itself very simple to understand) will have a large advantage, as cost to run the code will become more important.

AI will also make porting code to new languages (ones that provide better guarantees and performance) much easier than in the past.

## New Platforms

Often (though not always), new languages gain adoption based on the platforms they are optimized for. WebAssembly not only allows the first real alternative to JavaScript in the browser, it also is well optimized for near instant startup times, allowing it to run on lambda and other edge services. The LLVM already targets most existing hardware platforms, but WebAssembly (and specifically [WASI](https://wasi.dev/interfaces)) removes much of the complexity of supporting multiple platforms at a low level.

By targeting the LLVM and making WebAssembly a first class citizen, there is the possibility to have an ecosystem where all packages run across the web, server, edge, and mobile without any extra code to manage each platform.

As it stands now, each platform tends to have its own set of languages and package ecosystem, even though the same solutions are needed on each.


## Performance and Readable Code

In the past, languages sat along a line between `readable/easy to understand` and `performant`. The more performant the language, the more the programmer had to handle and describe to the compiler so it could optimize. (or the more escape hatches the language had to provide to allow hand written optimized code -- think of C's memory model for example, the source of thousands of security issues).

The reason for this linear correlation between complexity and performance often is down to the information available to the compiler. Languages that provided the compiler more information at compile time can perform optimizations not possible in languages with less information. Something as simple as the compiler having access to the lifetimes of an object can deliver orders of magnitude faster code.

Rust for example requires explicit annotation of value lifetimes in order for the compiler to understand what optimizations are permissable. Functional languages like Haskell can gather this information from things like the IO monad, but monadic code is difficult to write and understand.

We believe Effect Types provide the best of both worlds, extremely fast code (especially for parallel workflows), and code that is extremely simple to read and understand. Effect types allow for extremely clean code while still maintaining the data needed to perform the most advanced optimizations. Effect types allow the complexity of informing the compiler about various side effects to be pushed into the standard library and can be completely transparent to the user. 

Writing purely functional code gives the compilers a full understanding of how data flows. New algorithms now let us build an optimizer that delivers the same performance as complex to write hand optimized code: (see [1](https://www.microsoft.com/en-us/research/uploads/prod/2023/05/fip-tr-v2.pdf) and [2](https://halide-lang.org/papers/halide_autoscheduler_2019.pdf))

## Security

As AI writes more code, being able to understand the code without diving into every line will become more important. The benefits of AI generated diminish if you have to exhaustively review every line of generated code. StoutLang's Effect Type system can provide you a summary of all actions (effects) a piece of code does. This can be down to the function call level, modules, or whole libraries.

You can even see what effects a library uses in regards to your code.

Here's a contrived example of what a well behaved database library's effect types would look like:

```
## Sqlite.sl

new(db_path?: Str)
    - Env(name: "DATABASE_URL")
    - FileWrite(path: db_path | 'db_log.txt', content: Str)
    - FileRead(path: db_path, content: Str)
select(query: Str)
    - DbRead(table: Str)
    ...
```

The summary above is created from compile time information only. We can see that the only files accessed are the passed in `db_path` and `db_log.txt`

If we look at the DbRead, StoutLang is able to perform compile time evaluation of select calls to determine what tables a query will access.

```
db = Sqlite.new("mydb.sql")

db.select("SELECT * FROM some_table;")
```

If we hover over the select, we get the following effects:

```
## Sqlite#select

- DbRead(table: 'SomeTable')
```

While the DbRead effect depends on the Sqlite library emitting it, the FileWrite's are emitted when any file write occurs. This feature alone would have prevented the recent OpenSSL compromise. (because it would have been simple to see that the tests were overwriting binary files)

Using string literal types (similar to typescript), we can pass things like file paths through and expose them in the effect types. This can also be used on interpolated string literals to enforce things like correctly escaping any interpolated variables going into a database request. (So we can raise a compile error if you try to pass in a string that ever touched an unescaped interpolated variable) 

TODO: there's a lot more examples here I should write out.


## Parallel and Distributed

While EUV photo lithography provided some improvements to single core performance, we are unlikely to see major single core gains. As in the past decade, the evidence suggests that most of CPU performance improvements will happen by adding more cores. Current programming languages do not have a good story around concurrency. Async/await is an improvement over callback hell, but is a far cry from making concurrent programming simple. Async/await provides no guarantees you won't run into race conditions or dead locks. In languages with true concurrency (running multiple threads of code at once), you can mutate state on objects/variables and result in invalid states and very hard to debug crashes.

## Heterogeneous Processors

GPU, DPU, VPU, NPU, FPGA's, oh my.

## Language Servers

Most don't see it yet, but language servers provide an opportunity to fundamentally change the way we write code. In the past any languages that targeted anything other than just taking text in were doomed to fail. (See SmallTalk) The environment people edit their code in seems to be a very personal (if not religious) choice. Because of this constraint, programming languages had to build to the lowest common denominator (plain text), no assumptions could be made about information and tools available in an editor.

Language servers raise the bar for the "lowest common denominator" editing experience. In StoutLang, all effect type information is provided through the language server's hover tips. This helps keep code clean when you don't need to know the effects, but keeps the information a hover away. It also means as a user you don't need to worry about adding these annotations directly to your code.

## Bringing Functional Ideas to the Mainstream

There are a lot of great ideas buried in the depth of often mentioned, but seldom used functional programming languages (Haskell, Idris, OCaml, etc...) We always hear that functional programming is better, so why hasn't it gained traction. I have a few theories:

1. A prioritization of correctness over simplicity. (You can't have both unfortunately, choosing where correctness is necessary (memory safety) and where it's not ([`any` in typescript](https://effectivetypescript.com/2021/05/06/unsoundness/) for example) can mean the difference between a language thats easy to use and one thats seldom used.) (See https://en.wikipedia.org/wiki/Worse_is_better)

2. Familiarity. Learning any programming language is difficult. Learning one where the syntax is entirely foreign seems to be a tripping point for people. People are more willing to exert mental energy to learn their first programming language than their 2nd. They already know how to solve problems in their first language, so when learning a second, they weight the opportunity cost of learning the new language vs just implementing what they need in their new language. Functional programming languages tend to differ quite a bit from what I call `C style` that the majority of software developers learn in their first language. (C, C++, Java, C#, Rust, Go, JavaScript/TypeScript, and to a bit lesser extent Ruby and Python)

3. Complexity - Often as language designers, we want to make our language as powerful as possible. Monadic transformers are probably the best example of this. But with great power comes great confusion. I've heard it said that the hard part with designing a good board game isn't coming with a mechanic that makes it fun, it's coming up with a mechanic that makes it fun and can be understood in 5 minutes. I think the functional community has some great ideas, but for a language to go mainstream, we have to select from the ideas that can be quickly understood. Even if that means there is a slight loss in power. (Though I would argue, often you can get 80% of the power for 20% of the complexity)

4. Poor Marketing - The functional world tends to attract more academic programmers. For reasons I don't fully understand, once people are in the functional world for a year or two, they seem to lose the ability to explain concepts to developers who are new to functional programming. Part of this stems back to #3. If your language is complex, you have to explain more before you can get to the interesting features.

5. Unclear Benefits - The challenge the functional world faces is that the benefits of functional programming are often not clear until you're completely immersed in functional programming, but the trade-offs are immediately apparent. Open any Haskell book and you'll see that understanding the downsides of functional programming when you try to print. (And realize you have to understand a mountain of concepts to do something thats so simple in other languages) On the flip side, concepts like functional purity have a lot of benefits, but they won't be obvious until you've built a larger program.

Haskell makes the easy things hard so the hard things are easy.

With StoutLang, we believe effect types can finally make the hard things easy and keep the easy things easy as well.

---

Next lets quickly see why WebAssembly as a platform is such a game changer.

[Next - Why WebAssembly](why_webassembly.md)