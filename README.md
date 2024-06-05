# StoutLang

"If I had asked people what they wanted, they would have said a faster Python" - Me, at some point

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