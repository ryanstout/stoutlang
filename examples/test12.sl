struct Point {
    @x: Int
    @y: Int

}


def new(self: Point) -> Point {
    @x = 15
    @y = 20
    return self
}

def set_x(self: Point) -> Int {
    @x = 10
    return 0
}

def print_x(self: Point) -> Int {
    %> @x.to_s
    %> @y.to_s
    0
}


point = Point.new()

point.print_x()
point.set_x()
%> "ok"
point.print_x()

