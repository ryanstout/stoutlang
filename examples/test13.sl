struct Point {
    @x: Int
    @y: Int
  }

  def new(self: Point) -> Point {
    self
  }

  point = Point.new()

  %> point.i32_size.to_s