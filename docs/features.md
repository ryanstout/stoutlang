# Why Stoutlang?

We're entering a new age of software development. Severial large changes will drive the adoption of new languages.

## AI

We can expect that the *majority* of code going forward will be written by AI. While I don't expect AI to full replace developers in the short term, AI generating more and more code will change the priorities with reguards to languages and specifically saftey guarentees.

AI will significatly reduce the cost to write code, which will drive a greater emphasas on the cost of running the code. Languages that are able to run code faster (while keeping the code itself very simple to understand) will have a large advantage, as cost to run the code will become more important.

AI will also make porting code to new languages (ones that provide better guarentees and performance) much easier than in the past.

## Multiplatform



## Security


## Parallel and Distributed

While EUV photo lithography provided some improvements to single core performance, we are unlikely to see major single core gains. As in the past decade, the evidence suggests that most of CPU performance improvements will happen by adding more cores. Current programming languages do not have a good story around concurrency. Async/await is an improvement over callback hell, but is a far cry from making concurrent programming simple. Async/await provides no guaretees you won't run into race conditions or dead locks. In languages with true concurrency (running multiple threads of code at once), you can mutate state on objects/variables and result in invalid states and very hard to debug crashes.

## Heterogeneous Processors

GPU, DPU, VPU, NPU, FPGA's, oh my.

## Language Servers

Automatically adding in documentation to code..












There are a lot of great ideas buried in the depth of often mentioned, but seldom used functional programming languages (Haskell, Idris, OCaml, etc...) We always her that functional programming is better, so why hasn't it gained traction. I have a few theories:

1. Over emphasis