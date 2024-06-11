
struct Point {
    @x: Int32
    @y: Int32
}

def new(@: Point) -> Point {
    %> "Init Point"
    return(@)
}

puts "BEFORE POINT"
p = Point.new()
%> "After point"
p2 = Point.new()
%> "After 2"