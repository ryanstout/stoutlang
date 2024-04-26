#!/bin/bash

# Build each example in examples/ directory
for file in examples/*.sl
do
    base=$(basename "$file" .sl)
    echo "Build $base"
    ./bin/build "$file" "builds/$base"
done