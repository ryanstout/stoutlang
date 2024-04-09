# Effects

Effect are a simple concept that lead to cleaner code, better handling when things go wrong, and they give the compiler the information it needs to automatically generate extremely performant code without extra work on the developers part. 

Effects signal to the compiler where things like state, IO, and non-determinism live. Combined with StoutLang's pass by value semantics, the compiler can do automatic optimizations that are not possible in other languages.

Effects allow sections of code to easily change behavior in a simple and type safe way.


## Basic Effect Types

Below is a simple example that saves data of a certain type to a JSON file.
```
def save_person(person: Person) {
    File.write('person.json', JSON.dump(person))
}
```

If we hover over `save_person` in our editor, we can see not only it's return type, but also it's effects. There are two types of effects Actions and Errors. They vary only in their handling dynamics.

```
Return: Nil
Actions: [FileWriteAction]
Errors: [FileAccessError, DiskQuotaError, FileExistsError, ReadOnlyFileSystemError, FileIOError]
```

The effects from `File.write` tell us what the function can perform (mutable state, IO, non-determinism, and other side effects), in this case the `FileWriteAction`. The effect system will also tells us any errors that `File.write` might throw. (exceptions) The effects of a function are a union of the effects emitted by any code within the function. Lets add a 2nd function to `save_person` and see what effects we get:

```
def save_person(person: Person) {
    log("Saving ${person.name}...")
    File.write('person.json', JSON.dump(person))
}
```

Now we get both the effects from `File.write` and the effects from `log`:

```
# save_person
Return: Nil
Actions: [LogAction, FileWriteAction]
Errors: [FileAccessError, DiskQuotaError, FileExistsError, ReadOnlyFileSystemError, FileIOError]
```

Lets write a custom save_doctor function that then calls save_person.

```
def save_doctor(person: Person) {
    # The <= is sugar for creating a copy of the record and updating a property in the process, then assigning
    # it back to the original variable name.
    # 
    # Below is the same as: `person = Person({name: person.name, ...person})`
    person.name <= "Dr ${person.name}"
    save_person(person)
}
```

Now lets look at the return and effect types of `save_doctor`

```
# save_person
Return: Nil
Actions: [LogAction, FileWriteAction]
Errors: [FileAccessError, DiskQuotaError, FileExistsError, ReadOnlyFileSystemError, FileIOError]
```

Because save_doctor calls save_person, it inherits the effects of save_person. For clarification, the effect types of any function is a union of all functions it calls.


## Modifying behavior externally

Effect types allow you to change the behavior of large sections of code without needing to pass data through every function. You also don't need to rely on something like dependency injection, and everything type checks the whole way through.

In the `save_person` example above, we would normally want File.write to save a file to disk. (Since that's what we asked it to do), but when running tests, we might want File.write to change the path to a temp directory, only save in memory, or not save at all. Lets take a look at `File.write`'s implementation to see how we might accomplish that.

```
# The action effect definition
struct FileWriteAction < FileAction {
    def initialize(path: Path, contents: Str) {
        # ...
    }
}

struct File {
  def write(path, contents) {
    emit(FileWriteAction.new(path, contents)) { |file_write_action, _|
        # ... (the code to do the actual saving)
    }
  }
}
```

Notice that the actual file writing code (which is skipped here) is wrapped with an `emit`. The `emit` takes in an effect type, typically parameterized with the options we need to perform the action (more on effect parameters later), and performs the action in the emit's block.

In the `emit` example above, we have provided a "default handler" (the block passed to the function). In a typical program flow, the `path` and `contents` arguments will pass through to the block and the write code will be performed.

If we want to rely on the default handler, we can just call the code like:

```
File.write('myfile.txt', 'Hello world in a file')
```

Or we can call a function that calls File.write:

```
save_person(Person.new(name: "Ryan"))
```

But lets say we want to run the above code in a test. Instead of writing out the file, lets say we just want to save the file to an object in memory.

```
handle {
  save_person(Person.new(name: "Ryan"))
}.action(FileWriteAction) { |file_write_action, handler_chain|
  # save to an in memory record
  test_files[file_write_action.path] = file_write_action.contents
}
```

By wrapping the code in a handler (the `handle` syntax), we can replace the FileAction's handler.

The flow of the above works like so:
1. we setup the handler
2. the handle block is called.
3. `save_person` is called, which calls `File.write`.
4. `File.write` emits a FileWriteAction, which jumps into the main block of handle.
5. We save the file contents to a map.
6. `File.write` resumes *AFTER* the emit block.

If we wanted to, we could call the original `File.write` emit block and also save to a map:

```
handle {
  save_person(Person.new(name: "Ryan"))
}.action(FileWriteAction) { |file_write_action, handler_chain|
  # perform the File.write default handler (saving the file on disk)
  handler_chain[-1].call(file_write_action.path, file_write_action.content)

  # save to an in memory record
  test_files[file_write_action.path] = file_write_action.contents
}
```

If we were to call `save_person` more than once, the handler block would be called for each emit that matched the type in the first argument to `handle`.


## Example 2.

Lets do another example to make things clearer. In this case, we're going to introduce some state that we want to use across our program. Normally this would be global state. There's a lot of reasons to not do global state, but the one big reason to use global state is that it keeps functions cleaner. Especially for things that are unlikely to change often, using global state can be very tempting as a way to keep code from getting too messy.

In the example below, lets take a `save_purchase` function that takes a record and post it to an external REST api to record the purchase. In a case like this, we might be tempted to just inline the url we're going to POST to. It's unlikely to change.

However, we might end up wanting different urls when in staging and production. (Maybe we run tests against staging, so when testing, we want to hit the staging url). Below, we can use effects to keep `save_purchase` clean. The effects let us avoid needing to pass the url through layers of functions. Instead, we can define a program level handler to provide the url when it's needed.

```
def save_purchase(r: PurchaseInfo) {
  url = emit(GetPurchaseSaveUrlAction)
  post(url, r.to_json())
}
```

Unlike the previous effect example, the emit performed in `save_purchase` does not provide a default handler. If we try to call `save_purchase` without a handler, we will get the following compile time error:

```
Handler not provided: `save_purchase` requires a `GetPurchaseSaveUrlAction` handler
```

Lets provide one:

```
handle {
  save_purchase(r)
}.action(GetPurchaseSaveUrlAction) {
  'http://stripe.com/....'
}
```

When `save_purchase` emits the effect (GetPurchaseSaveUrlAction), it jumps to the outermost handler (for actions). From inside of the .action block, we could call the default handler if one existed, but in this case we're just going to return a url string. The returned url string gets returned from the emit function and `save_purchase` continues.

If we want, we can wrap our whole program in this handler, thus providing the save url across all of our codebase. Because concurrency in Stoutlang is done with coroutines and there are no asynchronous callbacks, handlers are guaranteed to be provided to all code launched from within the handler. (even if new coroutines are created along the way)

Instead of having an action for each piece of global configuration, you will typically have one handler that provides a configuration struct. Things like environment variables can also be provided in this way, the default handler will look up in the program's ENV, but giving you a way to easily override the lookup for testing, sandboxing, or changing config inside of a handler.





### Why is this Awesome?

The above doesn't seem too revolutionary, but it provides us with a lot of really useful properties for writing simple, typesafe, and extremely optimizable code.

1. **Practical features without the downsides** - In the functional world, there's a trade off. There's a lot of `bad things™` that make software development harder (in the long run) This is a long list: mutations, global state, side effects, non-determinism, exceptions, etc... Unfortunately, to get rid of these `bad things™`, we need to make our programs more complicated and harder to understand.

Effect types give us the best of both worlds. For example with global state, effect types deliver what feels like global state, but without the downsides. With side effects and IO, effect types make let us use side effects in a way that looks like normal procedural code, but provides information to the compiler so the unpredictability of side effects can be removed. (For example, the StoutLang compiler can automatically run code in parallel while still enforcing a total ordering)

2. **Simpler, easier to compose functions** - We didn't have to pass any state through to `save_person` to change the behavior. This allows us to code for the "normal workflow", then the emitted effects let us customize the behavior across a wide range of scenarios. Effect types also can save us from passing lots of arguments through every level. Instead we can just provide information where we care about it and pass it "down from on high".

**Note**: passing down from higher levels isn't possible in most languages due to asynchronous code. StoutLang doesn't have any asynchronous code (we can accomplish the same goals without it). This means every line of code runs has a handler stack that goes back to the start of the program. When we spawn a new coroutine, it maintains a copy of the handlers at the time it was spawned.

3. **We maintain composability.** Functional developers love functional composition. Unfortunately, monads can't be composed. So to have a function that has two side effects, you have to do a lot of Monad Transformer gymnastics. I'll spare you the details, but it gets complex fast.

Effect types make it easy for us to compose our functions.


## Other Effect Type Features

Effect types also let you stop running the handle block at any point.

TODO: Explain handler halting

TODO: Parametric Effects



## Error Handling

[From Ryan. There's a few big articles on why StoutLang exceptions are better than Option types and traditional exceptions... This I put together quickly. Also, I'm not a Rust expert, so I need to brush up a bit, just using it as an example.]

tl;dr Exception handling (we call them errors) can be done with effect types, only everything type checks, both the happy path and the exception path. The compiler also tells you if you don't handle a possible exception, and you can provide top level handlers for the things you don't care about handling. (File IO errors, for example, if you just want to assume that the disk works as expected)

This gives you the benefits of Option/Maybe/Result types (see below), but with way less code and complexity.

### What's wrong with Option/Maybe/Result?

If you've never used an Option/Maybe/Result type (the way errors are handled in Rust, Haskell, Scala, Swift, etc..), you can skip to the StoutLang errors.

In the past few years, we've seen Option types gain popularity over Exceptions for a few reasons:

1. Explicit documentation about where code can fail.
2. You are required to handle the errors.
3. They avoid side effects (exceptions)

StoutLang takes a different approach, giving you Exceptions that have the benefits of Option types, but keeping your code clean.

Before we dive in, lets talk about a few of the problems with Option types. We'll use Rust's option type as an example, but this applies in most languages with an option type.

1. Options can only handle one type. Here's what the Rustlang docs say makes for a good error type:

```
- Represents different errors with the same type
- Presents nice error messages to the user
- Is easy to compare with other types
  - Good: Err(EmptyVec)
  - Bad: Err("Please use a vector with at least one element".to_owned())
- Can hold information about the error
  - Good: Err(BadChar(c, position))
  - Bad: Err("+ cannot be used here".to_owned())
- Composes well with other errors
```

"Represents different errors with the same type" might sound a little strange. The reason for this isn't that it's the ideal way to represent an error, it's that making Option type check requires all errors be the same type. There's so much more information we can pass about an error, but in Rust a ton of different types of errors end up as io::Error's. Sure, you can use an enum to combine multiple error types, but that brings us to the 2nd problem.

2. Options must be propagated

Lets take a look at calling a function that could fail because of an int parsing error or a file io error. First Rust:

```
use std::fmt::{self, Display, Formatter};
use std::io;
use std::num::ParseIntError;

// Define a custom error type that can encapsulate different kinds of errors.
#[derive(Debug)]
enum MyError {
    Io(io::Error),
    ParseInt(ParseIntError),
}

impl Display for MyError {
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        match *self {
            MyError::Io(ref err) => write!(f, "IO error: {}", err),
            MyError::ParseInt(ref err) => write!(f, "Parse int error: {}", err),
        }
    }
}

impl std::error::Error for MyError {}

// Implement conversion from `io::Error` to `MyError`.
impl From<io::Error> for MyError {
    fn from(err: io::Error) -> MyError {
        MyError::Io(err)
    }
}

// Implement conversion from `ParseIntError` to `MyError`.
impl From<ParseIntError> for MyError {
    fn from(err: ParseIntError) -> MyError {
        MyError::ParseInt(err)
    }
}

// Function that might cause either `io::Error` or `ParseIntError`.
fn might_fail(input: &str) -> Result<i32, MyError> {
    if input == "io_error" {
        return Err(io::Error::new(io::ErrorKind::Other, "simulated IO error").into());
    }

    let parsed_number: i32 = input.parse()?;
    Ok(parsed_number)
}

// Function 'a' that calls 'might_fail'.
fn a(input: &str) -> Result<i32, MyError> {
    might_fail(input)
}

// Function 'b' that calls 'a'.
fn b(input: &str) -> Result<i32, MyError> {
    a(input)
}

// Usage of the functions in main.
fn main() {
    match b("100") {
        Ok(num) => println!("Parsed number: {}", num),
        Err(e) => println!("Error: {}", e),
    }
}
```

## StoutLang Errors

```
fun might_fail(str_of_number: Str) {
  str_of_number.to_i!

  File.read('missing_file.txt')
}

fun a() {
  might_fail()
}

fun b() {
  a()
}

handle {
  b()
}.catch(FileIOError) {
  # ...
}.catch(ParseIntError) {
  # ...
}
```

I think the above code speaks for itself, though honestly, Rust could make this simpler (and maybe there's some libraries that wrap it up the complexity better, I'm not a Rust expert)

3. No Stacktraces

When you ask people why Option's are better than Exceptions, one reason I hear a lot is that they are more performant. When I dig into that, people say that Exceptions are slow. I'm always amazed by this because that hasn't been true for more than a decade. Backend compilers like the LLVM can generate zero cost exception handling, where the normal path has no extra instructions in the path and the exception path only has a (very small) cost when finding the handler or generating a stack trace. (They have to walk the stack). But for a lot of code, you can monomorphise frequent paths and get zero cost for the handling also.

Languages that use Option types for exception handling tend to recommend you handle the exception as soon as it happens. This sounds good in theory, but most of the time you don't know how to handle it where it happens. If we're writing to a database and the disk fails to write, the database library itself can't know what the right way to handle it is. Maybe we can try it again, maybe we can just log to Sentry and keep going, it all depends on the code calling the database library.

In languages like Rust, exceptions end up getting passed up the call chain (which just from a code standpoint is complex), but worse, when the Err result ends up being handled, you have no idea where it came from. (Because it got merged with other similar errors in the path)

In StoutLang, handlers (even actions) provide a simple way to get a stack trace to the emit.


## StoutLang Errors

In StoutLang, exceptions are effects. Notice how the errors can pass through the calls to `a` and `b` without any extra code. (The type/effect system understands that both `a` and `b` can emit `FileIOError` and `ParseIntError` effects) 

Instead of being required to handle errors, we find it more practical to provide an easy to see any places in your code that may cause a crash. In your editor, functions with unhandled exceptions are underlined in yellow. You can rely on the default behavior (the app crashes), or you can add a handler upstream.

If you're ok with you're app crashing if the disk is full for example, you can just let the error bubble up to the top level.



## Summary

Effect types really feel like magic (in a good way) when you get the hang of them. They provide 80% of the benefits you get from a using a pure functional language, but are an order of magnitude simpler to understand. Under the hood, many of the code paths can be monomorphised (meaning there is no performance penalty compared to Option/Maybe/Result types).

I think my favorite thing about effect types is that you don't really need to think about them. Because the standard library implements effect types for all side effects, any code downstream (all code except calls to C or other languages (unsafe code)) automatically have the effects created and tracked.

Because effects are parameterized by the arguments to the core action, we can see at a high level exact details about what a chunk of code does. This kind of compile introspection has never been done before (that I'm aware). With more concern about security, and more AI generated code, I think these guarantees have never been more relevant.

---

Next lets take a look at how StoutLang does functions.

[Next - Functions](functions.md)