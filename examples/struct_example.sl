
struct Point {
    @x: Int32
    @y: Int32
}

def new(self: Point) -> Point {
    %> "Init Point"
    return(self)
}

puts "BEFORE POINT"
p = Point.new()
%> "After point"
p2 = Point.new()
%> "After 2"