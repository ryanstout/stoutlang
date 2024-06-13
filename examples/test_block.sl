def call_block(block: Int -> Int) -> Int{
  %> (5 + 2).to_s
  %> "call_block called"
  c = yield(3)
  %> "yield returned: "
  %> c.to_s

  # yield(5)

  # d = yield(5)
  # %> "yield returned: "
  # %> d.to_s
  5
}

call_block |x: Int| {
  %> "passed block called with: "
  %> x.to_s
  x
  # return x
  # 2
}