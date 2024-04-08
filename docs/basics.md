# StoutLang - The Basics

### StoutLang Feels: JavaScript-ish

StoutLang borrows a lot of syntax from JavaScript, which borrowed it from Java, C, etc..

Here's hello world:

```
=> "Hello World"
```

Ok, I just said we try to feel like JavaScript, but printing is a bit different. One goal with StoutLang is to make things take the "right" amount of space. So things that are extremely common (printing) are made to be shorter, and things that don't happen as much we may be longer but clearer. This makes code more readable in the long run.

In the above, `=>` is a unary infix function which prints. (Just read `=>` as `print`). It's the same as `=>("hello world")`

Most things from here will feel familiar I swear :-)

### Example Code

Lets write something more useful to get a feel for StoutLang

```

# Print the temperature of a location passed in as a string.
fun print_temperature(location: Str) {
    api_key = Env['OPENWEATHER_API_KEY']
    request_url = "http://api.openweathermap.org/data/2.5/weather?q=${location}&appid=${apiKey}&units=metric"

    response = Http.get(request_url)
    weather_data = Json.parse(response)
    => "The temperature in ${weather_data.name.to_s} is ${weather_data.main.temp.to_f}C"
}

# Get the users location and print the weather.
=> "Enter your location."
location = Console.read_line()
print_weather(location)
```

Lets save this as `get_weather.sl`

Now lets run our program using `sli` (the StoutLang Interpreter):

```
sli get_weather.sl
Bozeman
The temperature in Bozeman is 20C
```

This runs our code above. If we want to compile it to a statically linked binary, we can use `slc` the StoutLang compiler:

```
slc get_weather.sl
./get_weather
Bozeman
The temperature in Bozeman is 20C
```

From the above we can see the following:

- StoutLang uses `#` for comments.
- It uses { and } for blocks.  
- There is local type inference, only requiring types in function arguments.
- Some things are provided by default. Env, Json, and Http in this example. (Structs in this case, which group code) - don't worry, these are only compiled in if you use it.
- We can evaluate code in the main context.
- StoutLang can run both ahead of time and in an interpreter. There is also a REPL.

Here's some other things that StoutLang has:

- Pattern Matching
- A compact record update syntax
- 




# Basic Types


In StoutLang, types always start with a capital letter.

| Type category   | Types                                                       | Literals                              |
| Signed Numbers  | Int, Int32, Int64, Float, Float32, Float64 (< Number)       | 1, 200_u32, 99334.45, 99234.23_f32    |
| Strings         | Str, Bytes (a char is a length 1 string)                    | "hello world"                         |
| Booleans        | True, False (< Boolean)                                     | true, false                           |
| List            | List(...)                                                   | []  (example: [1,2,3,4] )             |
| Map             | Map(...)                                                    | {name: "Ryan", role: "Dev"}           |
| Tuple           | Tuple(...)                                                  | (1, "hello", 2)                       |

TODO: More Basics




---

Before we get too deep in the basics, lets introduce Effects, the big innovation in StoutLang.

[Next - Effects](effects.md)