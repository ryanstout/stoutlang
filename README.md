# StoutLang

## Install

```
brew install llvm@17

# ruby-ffi doesn't look at the right location
sudo mkdir -p /opt/local/
sudo ln -s $(brew --prefix llvm@18)/lib /opt/local/lib


could you track that a string was made by interpolating an unsanitized string, even if passed through stuff


# if statements

if (something) {
    # true block
} else {
    # false block
}

Could be syntactic sugar for

if(something, true_block).else(false_block)


# Feature Wishlist

- should be a way for emitted operations to be logged when they happen, so you
    can easily decide to turn on logging for all IO/file ops, network, etc..
- all methods and friends should be hashed and propagate up the hash. Then tests could only be run when some code that gets called changes.
    (maybe use the effect system for this?)
- easily distributed map reduce (ability to cluster running instances and specific nodes to run code on or have some algorithms to get code closer to the data)
    - seamless rpc calls to other nodes in the cluster (front-end websocket connection hanging around..)
    - When calling with RPC, network call failures are possible, how to do that would colored functions (it gets added as an effect on the call site?)
    - Way to sync code (based on hash), so distributed is easy
- you should be able to start with any types and have a hot key to fill in the type based on what’s calling it. (in LSP)
- you should be able to declare your “call type” and a function will be exported in that call type and called by the rest of Stoutlang in the call type. (Think llvm call types, or wasm single return value export)
- maybe untyped variables look at what gets assigned to them in the rest of the function for their type (union of) - typescript does this I think, so you can do:
```
a = 5
if {something} {
    a = 'cool'
}

a : int | str
```\


- “Unit types” (from typescript) represent the type winnowed to its value: 42 is a type 42 (and int) — https://youtu.be/AvV3GIDeLfo?si=NWdkT7mRbeM9kjUH
- is there a way to build in O notation, so the language calculates it for you. And maybe some memory guarantees (bounded)
- syntax to curry a function with only argument, or not all of the args and return a few function
- syntax to pass a value to a function and update it with the return value (sugar for calls that look mutating). Thinking .save() on a record — user.save! could cause an update. (Sugar for user = user.save!())
    - to support chaining, it probably needs a different method call syntax.
    - chaining is tricky.
    - The bang in the method name would be nice to enforce that it updates the original variable, but either way the end user is going to have to think about how to propigate the changes.
        - user.deactivate!.save!
    - maybe tell that a "mutation" (bang) funciton was called and there were no side effects and the new value wasn't propigated.
        ```
        def rename
            user.name = "Ryan"
        end

        ## Warning! user was changed, but not saved.

        user.save! (no warning since it has side effects)

        ## Maybe call syntax like:
        user<=save! -- don't love that it's got a less than in it, 2 chars
        user@save!
        user:save!
        user'save!
        user~save!

- How about a > function for print, unary operator, so no parens (maybe that's log.info not a print), then you could do !> for error or something? etc...
- If we distinguish world read side effects (file read, db read, etc..) vs world writes/mutations (file write, db update, etc..) we can make functions transactionional up until the writes.
- You'll want a way to access the parent handlers (and probably a way to access the whole chain so you can skip some if you want)
- Maybe custom infix operations  def (*++*)  { ... }
- String literals with interpolation need a way to hook, so you could build things like svelt from heredocs or something.
- A way to shell out using cgroups where you only permit certain effects. (You would have to specify the effects ahead of time, since the programs can't emit them)

- package manager: https://medium.com/@sdboyer/so-you-want-to-write-a-package-manager-4ae9c17d9527
    - packages need a way to be parameterized (build target, compiler options, optimization level, etc..)
    - sub-dependencies could use the main version if possible, and if not run on a seperate version (code size advantages and compatability if you can depend on the same version)
    - languages that build to the front-end need to think about compile size
    - there is probably a static analysis way to determine if versions are compatiable. (Do they implement interface bondraries correctly, +1 for real interfaces over structural typing)
    - need ability to parameterize package selection also (on this platform package X, on this platform package Y.. in dev install package X, etc..)

- version source files. (.sl1 = stoutlang v1, .sl2 ..etc..) - then you could guarentee interop between versions going forward (at the call layer)
- need a ruby include equivilent to bring identifiers into scope:
    - use Queue.Immutable.{ make }
    - use List.*

- Should be able to walk backwards from function signatures in order to create automatic, profiling code
- Erlang and Koka do thread specific heaps, which allows for GC to happen per heap, providing less pause the world. The trade off is more cost when sharing across threads, but this could be optimized by a work scheduler to minimize cross thread communication.

- Built in Fully Homomorphic Encryption mode for all data structures?

### Transactional/ACID Functions
- A way to make functions that don't have certain side effects transactional
    - Could let you implement optimistic locking everywhere, good for parallel
        - For example on a web request, if changes happen to a model before the 
- If you have reads, then writes (in that order), you could somehow queue the writes to confirm they would all execute, then run them.
    - Probably needs a virtual file system that you can "write to", then "read from", then flush.
    - Maybe any IO type things need to implement a Deferable or Transactional effect to make this work? When done the transaction runner calls .flush on the effect






Would be nice if effect types were composable in different ways. Inheritance is tricky here, in some cases you want to handle the core reason for the failure 
DatabaseCallTimeout < TcpNetworkRequestTimeout

HttpGetRequest < HttpRequest < TcpSocketRequest < ....


# Effect Types
- retry and continue in exceptions or handlers should be first class
- how do we get the return type of emit? (A union of all handler return types probably?.. We probably want to be able to constrain the return type at the emit or in the effect type) -- thought about EffectType.emit { ... }

## Effect Type Syntax
maybe effect types need some way to see they are effects?

## Mocking on effect types
Maybe effect types could have a way to override behaviors for easy mocking.


> HttpGetRequest, ThrowHttpGetRequestFailed
def get_url(url: str):
  return Http.get(url).body


HttpGetRequest.mock_url_fetch(url, '<body></body>') {
    get_url(...)
}

# Upgrades? / Wrapping

Should effect types have a way to upgrade them to higher level instances
(maybe just wrap them?)

If you're http library is creating an http request, you're using the Tcp library,
the tcp calls are going to emit tcp effects. Do you wrap it in a new Http event?

Wrapping should be required, if the wrapped type doesn't reference the original somehow, you get a type error (so you can extract all of the effects if you want)

Probably needs to be inheritance and adding new information so you can catch at the parent class level


## Generics

If all types are Capitalized, maybe type variables are lower case?

# Marketing

programming language design is a multi dimensional optimization problem. Good languages optimize all things some: English readability, expressiveness, performance, safety (type and memory), cognitive load.

- fake meat example for Marketing. Lots of good ideas in functional programming, but doesn't fit well enough with the way humans are wired.

- Bigger building blocks means AI can write more
    - Cognitive load applies to humans and AI (for now)
- Benchmark examples to show fast rust is complicated
- Functional has too many trade offs. A world without trade offs
- Good to show data points about how lines of rust shipped (or maybe effective lines)