# Effects

Effects serve three purposes.

Effect types are a simple concept that leads to cleaner code, better handling when things go wrong, and gives the compiler the information needed to automatically generate exteremely performant code without any extra work on the developers part. 

1. They signal to the compiler where things like state, IO, and non-determinism live so the compiler can do automatic optimizations that up until not been possible.
2. They provide a way to have pure functions even when doing state mutations or IO.


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
    log("Saving #{person.name}...")
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





## Error Handling

In the past few years, we've seen Option types gain popularity over Exceptions for a few reasons:

1. Explicit documentation about where code can fail.
2. You are required 

