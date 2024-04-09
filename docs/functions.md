# Functions

Before we introduce functions, lets talk about how you call functions. StoutLang lets you call functions two different ways.

**Function Style**

Lets say we have a `Weather` struct with a static `lookup` function.

```
import weather

bozeman_weather = Weather.lookup("Bozeman")
bozeman_temperature = current_temperature(bozeman_weather, "Celsius")
```

Weather provides some functions when we import it. Functions with the same name can exist in a scope. When you call a function, it looks at the types of the arguments to figure out which version to call. (This is usually called function overloading)

**Method Style**

StoutLang also provides a second functional call syntax. This style looks more like a method call, but it's exactly the same as the function style under the hood. Lets look at an example.

```
import weather

bozeman_weather = Weather.lookup("Bozeman")
bozeman_temperature = bozeman_weather.current_temperature("Celsius")
```

Notice this time we did `bozeman_weather.current_temperature("Celsius")` instead of `current_temperature(bozeman_weather, "Celsius")`.

The `.{function_name}` syntax takes the argument to the left of the dot and passes it in as the first argument to the function. This gives the feel of Object Oriented programming, but as we'll see later, few of the downsides.

The advantage of the method style is it allows you to chain operations, resulting in smaller code, which personally I find easier to read/write. It's usually easier to think about telling a `cow` to `moo`, than having a `moo` function that takes a `cow`. (in English at least)

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

## Open/Close Problem and Composability

One common problem in Object Oriented programming languages is the "Open/Closed" problem. Ideally we want to be able to work with collections of data (records, objects, structs, etc..) in certain ways. We want the functions that work with the collection to be Open for Extension, but Closed for Modification. ([More on Open/Closed principle here](https://en.wikipedia.org/wiki/Open%E2%80%93closed_principle)) The method style syntax gives us the benefits of OOP, without the need to modify objects to add new methods. Instead, we can add new functions to the current scope that take the struct (like an Object) as the first argument, and use them (only within the scope) as if they were on the struct itself. This also means our functions are first class functions, can easily be passed around, composed, etc...

Lets say our weather library only supported Celsius and Fahrenheit, and because it's really cold in Bozeman, we want Kelvin also. We can add a `current_temperature_kelvin()` function:

```
import weather

fun current_temperature_kelvin(self: Weather) {
  return .current_temperature("Celsius") + 273.15
}

bozeman_weather = Weather.lookup("Bozeman")
bozeman_temperature = bozeman_weather.current_temperature_kelvin()
```

Note: the . before current_temperature tells us that we are calling current_temperature on self. (method style) We could also have passed in `bozeman_weather` in as the first argument (function style)

If we wanted, we could put `current_temperature_kelvin` in another file and import it. As long as it's imported into the scope before we call it, it will be available and you can call it in either style.

We can also emulate some object oriented behaviors. Lets say in our scope, we wanted `current_temperature` to support taking "Kelvin" as an argument (instead of making a new function).

```
import weather

fun current_temperature(self: Weather, unit: Str) {
  if unit == "Kelvin" {
    return self.super("Celsius") + 273.15
  } else {
    return self.super(unit)
  }
}

bozeman_weather = Weather.lookup("Bozeman")
bozeman_temperature = bozeman_weather.current_temperature("Kelvin")
```

`super` above calls the same function name (from the functions available in the current scope), possibly with different arguments.

Once we create our new `current_temperature` function, it essentially replaces the previous `current_temperature` function (from `import weather`) for the rest of the scope.

Unlike Object Oriented languages, the functions or Struct's in a file can be imported separately. (Though usually they aren't). Unless you have a reason to, we recommend importing everything in a file. Since most functions in files take structs as their first argument, 



With StoutLang's method call style, you get the best of both worlds, the clarity and flexibility of functions with the ergonomics of method call syntax.

---

Next lets look at how StoutLang simplifies the type system and macros.

[Next - Unified Compile and Runtime Code](unified_compile_and_runtime_code.md)