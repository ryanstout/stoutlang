def combine(a: Int, b: Int, block: (Int, Int) -> Int) {
  yield(a, b)
}

result = combine(10, 20) |a: Int, b: Int| {
  a + b
}

%> result.to_s