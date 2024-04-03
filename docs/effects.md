# Effects

Effects serve three purposes.

Effect are a simple concept that leads to cleaner code, better handling when things go wrong, and gives the compiler the information needed to automatically generate exteremely performant code without any extra work on the developers part. 

1. They signal to the compiler where things like state, IO, and non-determinism live so the compiler can do automatic optimizations that up until now were not possible.
2. They allow sections of code to easily change behavior in a simple and type safe way.
3. They allow


## Basic Effect Types

Below is a simple example that saves data of a certain type to a JSON file.
```
def save_person(person: Person) {
    File.write('person.json', JSON.dump(person))
}
```

If we hover over `save_person` on our editor, we can see not only it's return type, but also it's effects.

```
Return: Nil, Effects: [FileWriteAction, FileAccessError, DiskQuotaError, FileExistsError, ReadOnlyFileSystemError, FileIOError]
```

The effects for `File.write` tell us the function can perform actions (mutable state, IO, non-determinism, etc..), in this case the `FileWriteAction`. It also tells us any errors that `File.write` might throw. The effects of a function are a union of the effects emitted by any code within the function. Lets add a 2nd function to `save_person` and see what effects we get:

```
def save_person(person: Person) {
    log("Saving ${person.name}...")
    File.write('person.json', JSON.dump(person))
}
```

Now we get both the effects from `File.write` and the effects from `log`:

```
# save_person
Return: Nil, Effects: [LogAction, FileWriteAction, FileAccessError, DiskQuotaError, FileExistsError, ReadOnlyFileSystemError, FileIOError]
```

Lets write a custom save_doctor function that then calls save_person.

```
def save_doctor(person: Person) {
    # The <= is sugar for creating a copy of the record and updating a property in the process, then assigning
    # it back to the orignal variable name.
    # 
    # Below is the same as: `person = Person({name: person.name, ...person})`
    person.name <= "Dr ${person.name}"
    save_person(person)
}
```

Now lets look at the return and effect types of `save_doctor`

```
# save_person
Return: Nil, Effects: [LogAction, FileWriteAction, FileAccessError, DiskQuotaError, FileExistsError, ReadOnlyFileSystemError, FileIOError]
```

Because save_doctor calls save_person, it inherits the effects of save_person. For clarification, the effect types of any function is a union of all functions it calls.


## Modifying behavior externally

Effect types allow you to change the behavior of large sections of code without needing to pass data through every function.

In the `save_person` example above, we would normally want File.write to save a file to disk. (Since that's what we asked it to do), but when running tests, we might want File.write to change the path to a temp directory, only save in memory, or not save at all. Lets take a look at `File.write`'s implementation to see how we might accomplish that.

```
struct FileWriteAction < FileAction {
    def initialize(path: Path, contents: Str) {
        # ...
    }
}

struct File {
  def write(path, contents) {
    emit(FileWriteAction, path, contents) { |path, contents| 
        # ... (the code to do the actual saving)
    }
  }
}
```

Notice that the actual file writing code (which is skipped here) is wrapped with an `emit`. The `emit` takes in an effect type, typically parameterized with the options we need to perform the action, and performs the action. In the `emit` example above, we have provided a default handler (the block passed to the function). In a typical program flow, the `path` and `contents` arguments will pass through to the block and the write code will be performed.

But lets say we want to run this code in a test. Instead of writing out the file, lets say we just want to save the file to an object in memory.

```
handle {
  save_person(Person.new(name: "Ryan"))
}.action(FileWriteAction) { |file_write_action, handler_chain|
  # save to an in memory record
  test_files[file_write_action.path] = contents

}
```

The flow of the above works like so:
1. we setup the handler
2. the run block is called
3. `save_person` is called, which calls `File.write`.
4. `File.write` emits a FileWriteAction, which jumps into the main block of handle.
5. We save the file contents to a map.
6. `File.write` resumes *AFTER* the emit block.

If we wanted to, we could call the original `File.write` emit block and save to a map:

```
handle {
  save_person(Person.new(name: "Ryan"))
}.action(FileWriteAction) { |file_write_action, handler_chain|
  # perform the File.write default handler (saving the file on disk)
  handler_chain[-1].call(file_write_action.path, file_write_action.content)

  # save to an in memory record
  test_files[file_write_action.path] = contents
}
```

If we were to call `save_person` more than once, the handler block would be called for each emit that matched the type in the first argument to `handle`.


## Example 2.

Lets do another example to make things clearer. In this case, we're going to introduce some state that we want to use across our program. Normally this would be global state. There's a lot of reasons to not do global state, but the one big reason is it keeps the rest of the program clean. Especially for things that are unlikely to change often, using global state can be very tempting as a way to keep code from getting too messy.

In the example below, lets take a `save_purchase` function that takes a record and post it to an external REST api to record the purchase. In a case like this, we might be tempted to just inline the url we're going to POST to. It's unlikely to change. We might end up wanting different urls when in staging and production. (Maybe when we're testing in staging, we also want to hit the staging url).

```
def save_purchase(r: PurchaseInfo) {
  url = emit(GetPurchaseSaveUrlAction)
  post(url, r.to_json())
}
```

Unlike the previous effect example, the emit performed in `save_purchase` does not provide a default handler. If we try to call `save_purchase` without a hanlder, we will get the following:

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

When save purchase emits the effect (GetPurchaseSaveUrlAction), it jumps to the outermost handler. From inside of the .action block, we could call the default handler if one existed, but in this case we're just going to return a url string. The returned url string gets returned from the emit function and `save_purchase` continues.

If we want, we can wrap our whole program in this handler, thus providing the save url across all of our codebase. Because concurrency in Stoutlang is done with coroutines and there is no asynchronus callbacks, handlers are guarenteed to be provided to all code launched from within the handler.

Instead of having an action for each piece of global configuration, you will typically have one handler that provides a configuration struct. Things like environment variables can also be provided in this way, the default handler will look up in the program's ENV, but giving you a way to easily override the lookup for testing, sandboxing, or changing config inside of a handler.





### Why is this Awesome?

The above doesn't seem too revolutionary, but it provides us with a lot of really useful properties for writing simple, typesafe, and exteremely optimizable code.

1. In the functional world, there's a big trade off. There's a lot of `bad things™` that make software development harder (in the long run) This is a long list: mutations, global state, side effects, non-determinism, null, exceptions, etc... Unfortunately, to get rid of these `bad things™`, we need to make our programs more complicated and harder to understand.

Effect types give us the best of both worlds. For example with global state, effect types deliver what feels like global state, but without the downsides. With side effects and IO, effect types make let us use side effects in a way that looks like normal procedural code, but provides information to the compiler so the unpredictability of side effects can be removed. (For example, the StoutLang compiler can automatically run code in parallel while still enforcing a total ordering)

1. We didn't have to pass any state through to `save_person` to change the behavoir. This allows us to code for the "normal workflow", then the emitted effects let us customize the behaviour across a wide range of scenarios.

2. We maintain composability. By pulling the effects out of functions, we can have both high level building blocks as well as 




Lets say we had some code that would try to call `save_person` multiple times, but we wanted to stop the handle run block as soon as any



## Error Handling

In the past few years, we've seen Option types gain popularity over Exceptions for a few reasons:

1. Explicit documentation about where code can fail.
2. You are required 

