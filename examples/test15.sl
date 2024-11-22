k = 10

times(5) |i: Int| {
  k = k + 1
  %> k.to_s
}

%> "Ran 5 times"