# Functions

Before we introduce functions, lets talk about how you call functions. StoutLang lets you call functions two different ways.

**Function Style**

Lets say we have a Weather struct.

```
bozeman_weather = Weather.lookup("Bozeman")
bozeman_temperature = current_temperature(bozeman_weather, "Celsius")
```

Weather provides some functions when we import it. Functions with the same name can exist in a scope. Only functions with the same name and argument types are not allowed. (This is usually called function overloading)

**Method Style**

StoutLang also provides a second functional call syntax. This style looks more like a method call, but it's exactly the same as the above under the hood. Lets look at an example.

```
bozeman_weather = Weather.lookup("Bozeman")
bozeman_temperature = bozeman_weather.current_temperature("Celsius")
```

The `.{function_name}` syntax takes the argument to the left of the dot and passes it in as the first argument to the function. This gives a lot of the feel of Object Oriented programming, but as we'll see later, few of the downsides.

The advantage of the method style is it allows you to chain operations, resulting in smaller code, which personally I find easier to read. (It's usually easier to think about telling a `Cow` to `moo`, than having a `moo` function that takes a `Cow`)

Method style chaining is especially ergonomic for dealing with collections.

```
people.select { |p| p.age > 20 }
      .reject { |p| p.name.nil? }
      .sort_by { |p| p.age }
      .map { |p| "#{p[:name]} is #{p[:age]}" }
      .take(3)
```

The alternative is a lot harder to read/write imho:

```
take(
    map(
        sort_by(
            reject(
                select(people)  { |p| p.age > 20 }
            ) { |p| p.name.nil? }
        ) { |p| p.age }
    ) { |p| "#{p[:name]} is #{p[:age]}" }
, 3)
```

## Open/Close Problem

One common problem is Object Oriented programming languages is the "Open/Closed" problem. Ideally we want to be able to work with collections of data (records, objects, structs, etc..) in certain ways. We want the functions that work with the collection to be Open for Extension, but Closed for Modification. ([More on Open/Closed principle here](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle)) The method style syntax gives us the benifits of OOP, without the need to modify the objects at a later point. We can add new functions to the scope that take the struct as the first argument, and use them (only within the scope) as if they were on the struct itself. This also means our functions are first class functions, can easily be passed around, composed, etc...


With StoutLang's method call style, you get the best of both worlds, the clarity and flexibility of functions with the ergonomics of method call syntax.

---

Next lets look at how StoutLang simplifies the type system and macros.

[Next - Unified Compile and Runtime Code](unified_compile_and_runtime_code.md)