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

Variables in StoutLang never escape their scope. If pass `person_a` to a function, we pass a copy of `person_a`. (Using some advanced data structures we can eliminate the copy overhead and duplicate memory)


## Scopes

Scopes in StoutLang determine how variables, functions, and methods are looked up.

The following contain scopes.

- Files
- Structs
- Fn's, Def's, and Macro's
- Callbacks

Note that Blocks do not contain a scope, this means things like .each and if expressions don't create scopes.

