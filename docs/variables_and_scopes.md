# Variables and Scopes

## Variables

All values in StoutLang are immutable. Immutability provides some great guarantees that can help write better programs. Traditionally the trade-off to having everything be immutable is more verbose code. StoutLang provides syntactic sugar to make it easier to write and manage immutable code.

While the values of data can not change, StoutLang still has the concept of variables.

```
person_a = {name: 'Ryan'}
```

Within a scope, we can overwrite the value of our variable (`person_a` in this case).

```
person_a = {name: 'Ryan'}
> person_a['name']
person_a = {name: 'Bob'}
```

When we overwrite the value in a variable with a new value, we call it "shadowing".

Variables in StoutLang never escape their scope. If we pass `person_a` to a function, we pass a copy of `person_a`. (Using static analysis and advanced data structures we can eliminate the copy overhead and duplicate memory)

So in StoutLang, we don't have to worry about a value being changed when we pass it to a function. If the function wants to change the value, we have a few options.

## Structs

TODO: Below is a WIP.

We haven't talked much about Struct's yet, but they are essentially a collection of other Structs or Basic types. (Int, Float, Str, List, etc..)

Structs look like this:

```
struct Car {
  make: Str
  model: Str
  miles: Int
}
```

We can create functions that work with the Car struct like so:

```
fun new(self: Car, make: Str, model: Str) {
    @miles = 0
}

fun miles(self: Car) {
  @miles
}

fun miles=(self: Car, miles: Int) {
  @miles = miles
}

car = Car.new("Toyota", "Sienna")
car->miles = 500
# ^ sugar for `car = car.miles=(500)`
#   same as car = miles=(car, 500)

car->miles += 500
# ^ sugar for `car = car.miles=(car.miles + 500)`


fun save_drive(self: Car, miles: Int) {
    @miles += miles
}
```




```
struct Accidents {
  major: Boolean
  count: 0
}

struct Car {
  make: Str
  model: Str
  miles: Int
  accidents: Accidents
}

fun accidents(self: Car) {
  @accidents
}

fun accidents(self: Car, accidents) {
  @accidents = accidents
}

fun count(self: Accident) {
  @count
}

fun count=(self: Accident, count) {
  @count = count
}

car->.accidents->.count += 20
# ^ sugar for car = car=(car, accidents=(car, count=(car.accidents, car.accidents.count + 20)))

car = car->(car, accidents->(car, count->(car.accidents, car.accidents.count + 20)))

```

The `@` gives you access to a field of the Car directly.



1. Update Syntactic Sugar



## Scopes

Scopes in StoutLang determine how variables, functions, and methods are looked up.

The following contain scopes.

- Files
- Structs
- Fn's, Def's, and Macro's
- Callbacks

Note that Blocks do not contain a scope, this means things like .each and if expressions don't create scopes.

---

Lets look at how StoutLang handles concurrency and paraellelism.

[Next - Concurrency and Parallelism](parallelism.md)