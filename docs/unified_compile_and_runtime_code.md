# Unified Compile Time and Runtime Code

Most statically typed languages have a separate small language that runs at compile time. These languages often don't have a name. Sometimes we just call it the "type system" or "macros". These languages are typically very small compared to the main language, and often have nothing in common with the main language.

One reason for there being two languages is that compile time languages have different goals. They are usually designed to help transform the code in some way (macros), or resolve type constraints (the type system). What you don't want is your compile time language to be able to do everything your run time language can do. Typically type systems can't create loop. You also probably don't want your type system to be able to read/write to disk. But it would be nice if you could create a function that takes some types and returns new types.

In StoutLang, the compile time language is the same as the run time language, except that the compiler doesn't allow certain effects. (Writing to disk, divergence, unbounded iteration, etc..) This means you don't have to learn a 2nd system, and you can leverage any library at compile time. (Assuming the referenced code is included before it's reached by the compiler) It also means more of "core" of the language is done in the core library.

Being able to run the main language at compile time unlocks some interesting possibilities:

1. When combined with the effect system, you can introspect a lot more things at compile time. For example, we could pass in a string SQL query and at compile time see what tables it touches.

2. You are no longer dependent on the language authors to provide you the tooling needed to accomplish complex type transformations. (Things like Pick, Partial, Required, etc.. in TypeScript can all be implemented in the language itself)

3. This unified approach encourages the development of richer, compile-time validations and transformations, allowing for the implementation of more sophisticated static analysis tools directly in the main language, thereby expanding the capabilities of the language without requiring external tooling.

---

We'll cover macros and type functions later, for now, lets look at scopes in StoutLang:

[Next - Variables and Scopes](variables_and_scopes.md)