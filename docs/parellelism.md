# Parallelism

Being able to take advantage of all cores on a machine is more important than ever. I'll spare you the details, but going forward, single core performance is unlikely to rise much, and multi-core is going to keep going. The gap between single core programs and multi-core is going to get bigger and bigger. Yet few languages seem to get parallelism right. Most languages, parallel code is difficult to write. (or impossible) Lets first talk about some of the issues in current languages, then we'll talk about how to solve them.

## Async/Await

Async/await seems to be the most popular way to handle concurrency right now, prior to that callbacks were popular, and before that it was threads. All have their challenges.

So why did async/await get popular? It comes down to performance. Mostly that 10+ years ago, threads couldn't solve the [c10k problem](https://en.wikipedia.org/wiki/C10k_problem) (running 10k connections from a single process). The solution was to let the operating system handle all of the connections and to avoid threads all together. When a socket had information that needed processing, the OS would call into the program (via libraries like epoll and kqueue) and the program would process it. Once done the program would check back to see if there was anything else that needed processed. This repeated in a loop, commonly called the event loop.

This got rid of the overhead associated with threads and thread switching. But it introduced a ton of complexity because everything had to be handled in callbacks. So Async/Await was added. One reason async/await got so popular is that it's something you can add on to a language later, with only minor adjustments to the compiler. (It can be implemented as a fairly simple [CSP[(https://en.wikipedia.org/wiki/Continuation-passing_style)] transform under the hood) Better solutions are a lot harder to bolt on to a language later.

So what's wrong with async/await you might ask?

1. **Colored Functions** - I won't rehash too much of this, Bob Nystrom did a great job laying out the issue [here](https://journal.stuffwithstuff.com/2015/02/01/what-color-is-your-function/) in 2015. The basic idea is that things like async/await require you to know the "color" of a function (do I call it with async or call it normal?). When you can only call an async function from another async function, things get complicated.

2. **Stacktraces/Error Handling** - Async/await has another big problem in most languages, and that's stack traces. If an exception happens in an async routine, the stack trace usually only goes back to the point where you awaited. (Some languages and runtimes have ways to track this through await's, but it seems to be rare). This is such a common issue, I bet you're thinking of a time you've been burned by this before right now :-)

3. **Library Interop** - For languages like Python especially, async/await doesn't play well with existing libraries. So if you want to use async/await, you have to only use async/await compatible libraries. A single threaded library in the async path will block the event loop and cause all sorts of issues. Languages like Rust and JavaScript runtimes like Node end up having different API's for asynchronous and synchronous API's.

4. **Not Parallel** - Even though async/await can solve the c10k problem. (You can maintain 10k connections from a single process), what you can't do is any meaningful amount of processing over those 10k connections. For that we need to use all cores on a machine. Unfortunately, JavaScript, Python, C#, and some Rust async runtimes only use a single core. (In Rust the details of async are handled at the library level, which makes library compatibility even more complicated.) In languages like 

If only there was a way to get the performance of async/await without the complexity, and take advantage of all cores. It turns out there is. A few languages get this right. Namely Go and Erlang (and other Beam languages).

In a perfect world we would write synchronous code without any function color (async), and that code would run in both concurrently (sharing time with other code on the same core) and parallel (running at the same time as other code on different cores). Coroutines to the rescue.

Coroutines give you something that feels a lot like a thread. You can "yield" code, which pauses the currently running code and jumps to a scheduler which picks the next code to run. Unlike threads, which are "preemptive" (they can stop at any point, via some cpu instructions), coroutines are "cooperative", meaning the running code has to say "I'm going to pause so something else can run".

The obvious place for a coroutine to pause is when it's waiting for IO. So languages like Go automatically yield the running coroutine when IO calls happen. The OS lets the coroutine scheduler know when that IO is done so the scheduler can resume the coroutine. From the programmers perspective, you just write normal synchronous code and it shares time with all other coroutines.

Languages like Go and Erlang also create more than one coroutine pool (usually one for each cpu core) via threads. The cost to launch a thread only has to be paid once per core, and there is no thread switching, which is slow. Erlang (and now Go as of a 1.14) also inject yield points into long running CPU code so that no coroutine takes up too much time.

The cost to switch from one coroutine to another ends up looking a lot like simple function calls once compiled down. It's much cheaper than threads, but the interface is the same as synchronous code. Because this is "the way" to do parallelism in these languages, all libraries support it and you never have to deal with odd compatibility issues. You also get full stack traces. Using something like Go channels can provide a nice synchronization primitive between coroutines.

Erlang was released in 1986, yet we're still fumbling around with async/await and all of it's complexity in 2024.

## StoutLang's concurrency/parallelism.

StoutLang borrows the good ideas from Go and Erlang. Concurrency is built on coroutines. You can spawn a new coroutine with the `spawn` call. All libraries (including the standard library) use coroutines under the hood. You get the simplicity of synchronous code, with the performance of async code. (And you can saturate all cores).

Ok, so thats the start of StoutLang's parallelism story. (Steal good ideas from Go and Erlang). Lets talk about what StoutLang can do thats different. In Go and Erlang you build parallel programs through something called the actor model. You spawn new coroutines (goroutines in Go, points for clever naming), and you manage state through channels or mailboxes. (asynchronous message queues).

Channels are a good abstraction and help prevent common issues with parallel code like deadlocks. (Though you trade deadlocks for the possibility of running out of ram because a channel is full, once you add backpressure (which you need for real programs), you can get deadlocks again)

StoutLang does something novel. Automatic parallelization. 

## Automatic parallelization

Most current languages don't have the information needed to be able to automatically parallelize code. Lets look at what would be needed and how we might add it.


Automatic parallelization is the big reason why you need a new language, it would be impossible to bolt this on to an existing language.

Lets start with the basics, we're iterating over list elements in a loop. This seems like languages should just run the loop in parallel by default right? But they don't, the reason being that the code in the loop can easily change things outside of the loop. (aka "side effects") Any code with side effects


TODO:



colored functions, non-composable, different libraries (async vs sync), async sucks...

evented performance for free
    - things get popular because they improve performance, then stockhome syndrome sets in
    - sync code blocks reactors (languages need to inject coroutine yields like erlang does)
    - no backpressure - can't build production apps without backpressure

