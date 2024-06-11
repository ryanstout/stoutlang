struct Point {
    @x: Int
    @y: Int

}

def set_x(@: Point) -> Int {
    @x = 10
    return 0
}

def print_x(@: Point) -> Int {
    %> @x.to_s
    %> @y.to_s
    0
}


point = Point.new(12, 14)

point.print_x()
point.set_x()
%> "ok"
point.print_x()

