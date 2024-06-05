# Structs

## TODO: ....

## Properties

Properties on a struct can be defined with `@prop_name: Type`

```
struct Point {
    @x: Int
    @y: Int
}
```

You can also provide default values

```
struct Point {
    @x = 0
    @y = 0
}
```

If you specify a default value, the type will be that of the default value.

## Constructor

To construct an instance of a struct, you call StructName.new() (or new(StructName)).

Methods named `new` act as the constructor for a struct. The first argument is always of the struct type. We use the `@` symbol for the name (similar to self in python).

```
struct Point {
    @x: Int
    @y: Int

    def new(@: Point) {
        @x = 0
        @y = 0
    }
}
```

Notice above that the `@` symbol lets us directly access properties on the struct instance using `@prop_name`

Keep in mind you can define multiple `new` functions with different arguments. You can define them inside or outside of the struct's body. If we wanted to add a new constructor for a point, we can like so:

```
def new(self: Point, x: Int, y: Int) {

}
```


## Encapsulation

One unique thing about StoutLang is that you can only access properties on a struct through the `@` argument. Props by default automatically generate getters and setters.

```
struct Point {
    @x = 0
    @y = 0
}

point = Point.new()

point.x
#=> 0

point.x = 5
#=> nil

point.x
#=>5
```

Remember you can also do:

```
x(point)
#=> 0

x=(point, 5)
#=>nil

x(point)
#=>5
```

The setter/getter methods ensure you control the api to your struct and can easily change the underlying implementation or storage by overriding the getter/setters.

TODO: More details on why encapsulation is a good idea, explain how this provides a functional looking data structure if you want it, but it's fully encapsulated.