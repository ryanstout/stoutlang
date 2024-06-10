struct Point {
    @x: Int
    @y: Int
}
def new(self: Point) -> Point {
    @x = 15
    return self
}

def print_x(self: Point) -> Int {
    %> @x.to_s
    0
}

point = Point.new()

point.print_x()
# %> "ok"
# point.print_x()

