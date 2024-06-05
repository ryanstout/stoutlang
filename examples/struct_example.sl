
struct Point {
    @x: Int32
    @y: Int32
}

def new(self: Point) -> Int {
    %> "Init Point"
    %> i32_size.to_s
    0
}

Point.new()