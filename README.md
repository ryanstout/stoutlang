# StoutLang

"If I had asked people what they wanted, they would have said a faster Python" - Me, at some point

## Update Nov 2024

StoutLang was an experimental language to build a language with a practical and easy to use (mostly hidden) effect type system. The goal was to be AOT compiled to LLVM, TypeScript looking syntax, Statically linked, and automatically parallelized.

I made some good headways, but decided to pivot to some more immediate opportunities. Hopefully I can revisit some day.


## Learn

New to StoutLang? [Start Here](https://github.com/ryanstout/stoutlang/blob/master/docs/overview.md)


## Install

```
brew install llvm@18

# ruby-ffi doesn't look at the right location
sudo mkdir -p /opt/local/
sudo ln -s $(brew --prefix llvm@18)/lib /opt/local/lib
```

## Interpreter


```
./bin/run {.sl file path}

./bin/run examples/test2.sl
```

## AOT compile


```
./bin/build {.sl file path} {output file path}

./bin/build examples/test2.sl test

./bin/build core/core.sl builds/core --lib --aot
```

## Debugging

lldb -- lli ./builds/test5.ll

## Tips

Run with --ir -O0 to see the LLVM IR with deadcode eliminated