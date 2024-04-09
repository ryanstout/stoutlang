# StoutLang

## Learn

New to StoutLang? [Start Here](https://github.com/ryanstout/stoutlang/blob/master/docs/overview.md)


## Install

```
brew install llvm@17

# ruby-ffi doesn't look at the right location
sudo mkdir -p /opt/local/
sudo ln -s $(brew --prefix llvm@18)/lib /opt/local/lib
```

## Interpreter


```
./bin/build {.sl file path} {output file path}

./bin/build examples/test2.sl test
```

## AOT compile

```
