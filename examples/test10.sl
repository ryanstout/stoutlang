struct Point {
    @x: Int
    @y: Int

    def init(self: Point) -> Point {
    #   %> x.to_s()
      %> "Run init"
      self
    }
}

r```
point = lookup_identifier('Point')
# pointer = bb.alloca(point.ir)

i32_size_func = mod.functions["sl1.i32_size()->Int"]
i32_size = bb.call(i32_size_func)

malloc_func = mod.functions['malloc']
pointer = bb.call(malloc_func, i32_size)

call_func = mod.functions["sl1.init(Point)->Point"]
call = bb.call(call_func, pointer)
```

%> i32_size().to_s()
# p = Point(1, 2)