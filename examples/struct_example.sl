
struct Point {
    @x: Int32
    @y: Int32
}

def new(self: Point) -> Point {
    %> "Init Point"
    %> self.i32_size.to_s
    return(self)
}

puts "BEFORE POINT"
p = Point.new()
%> "After point"
p
