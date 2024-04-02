# Why Stoutlang?

We're entering a new age of software development. Severial large changes will drive the adoption of new languages.

## AI

We can expect that the *majority* of code going forward will be written by AI. While I don't expect AI to full replace developers in the short term, AI generating more and more code will change the priorities with reguards to languages and specifically saftey guarentees.

AI will significatly reduce the cost to write code, which will drive a greater emphasas on the cost of running the code. Languages that are able to run code faster (while keeping the code itself very simple to understand) will have a large advantage, as cost to run the code will become more important.

AI will also make porting code to new languages (ones that provide better guarentees and performance) much easier than in the past.

## Multiplatform


## Performance and Readable Code

In the past, languages sat along a line between [extremely readable/easy to understand] and [extremely performant]. The reason for this linear correlation often is down to the information available to the compiler. Languages that provided the compiler more information at compile time can perform optimizations not possible in languages with less information. Something as simple as the compiler having access to the lifetimes of an object can deliver orders of magnitued faster code.

Even languages like Rust don't have full information on when a value may be changed by another thread, requiring adding of synchrnoization primitives that significantly slow down code. Functional languages like Haskell can gather this information from things like the IO monad, but monadic code is difficult to write and understand.

We believe effect types provide the best of both worlds, extremely fast code (especially for parallel workflows), and code that is extremely simple to read and understand. Effect types and syntactic sugar that makes record updates.

Writing purely functional code gives the compilers a full understanding of how data flows. New algorithms now let us build an optimizer that delivers the same performance as much more complex to write hand optimized code: (see https://www.microsoft.com/en-us/research/uploads/prod/2023/05/fip-tr-v2.pdf)

## Security


## Parallel and Distributed

While EUV photo lithography provided some improvements to single core performance, we are unlikely to see major single core gains. As in the past decade, the evidence suggests that most of CPU performance improvements will happen by adding more cores. Current programming languages do not have a good story around concurrency. Async/await is an improvement over callback hell, but is a far cry from making concurrent programming simple. Async/await provides no guaretees you won't run into race conditions or dead locks. In languages with true concurrency (running multiple threads of code at once), you can mutate state on objects/variables and result in invalid states and very hard to debug crashes.

## Heterogeneous Processors

GPU, DPU, VPU, NPU, FPGA's, oh my.

## Language Servers

Automatically adding in documentation to code..












There are a lot of great ideas buried in the depth of often mentioned, but seldom used functional programming languages (Haskell, Idris, OCaml, etc...) We always her that functional programming is better, so why hasn't it gained traction. I have a few theories:

1. Over emphasis