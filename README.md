could you track that a string was made by interpolating an unsanitized string, even if passed through stuff


# if statements

if (something) {
    # true block
} else {
    # false block
}

Could be syntactic sugar for

if(something, true_block).else(false_block)


# Feature Wishlist

- should be a way for emitted operations to be logged when they happen, so you
    can easily decide to turn on logging for all IO/file ops, network, etc..