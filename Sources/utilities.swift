// TODO: Make this into an iterator
class Peekable<T> where T: Sequence {
    var items: [T.Element] = []
    var position: Int
    
    var isAtEnd: Bool {
        get {
            return position >= items.count
        }
    }
    
    init(data: T) {
        self.position = 0
        for item in data {
            self.items.append(item)
        }
    }
    
    func peek() -> T.Element? {
        if position >= items.count {
            return Optional.none
        }
        
        return items[position]
    }
    
    func next() {
        if position >= items.count {
            return
        }
        
        position = position + 1
        return
    }
}
