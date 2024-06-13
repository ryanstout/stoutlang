def call_block(block: Int -> Int) {
  yield
}

call_block {
  %> "block called"
}