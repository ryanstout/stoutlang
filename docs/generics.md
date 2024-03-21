# Generics

```
class Array<'item> {
    def init(•items: 'item) {
        @items = items
    }

    def length {
        @items.length
    }

    def sort_by(block) {
        new_array: Array<'item> = []
        @items.each ...
    }
}


itms = Array<Int | String>(1,2,3,4,'Cool')

```
