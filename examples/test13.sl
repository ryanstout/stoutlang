struct Point {
  @x: Int
  @y: Int
}

point = Point.new(20, 10)

%> point.i32_size.to_s