enum Token : CustomStringConvertible {
    var description: String {
        switch self {
        case let .integer(int):
            return String(int)
        case let .op(op):
            return op.description
        case .lparen:
            return "("
        case .rparen:
            return ")"
        }
    }
    
    case integer(Int)
    case op(Operator)
    case lparen
    case rparen
    
    func isOperator() -> Bool {
        return switch self {
        case .op(_): true
        default: false
        }
    }
    
    func getPrecedence() -> Int8 {
        return switch self {
        case let .op(o):
            o.precedence
        default:
            0
        }
    }
    
    func isLeftAssociative() -> Bool {
        return switch self {
        case let .op(op):
            op.isLeftAssociative
        default:
            false
        }
    }
}

struct Operator : CustomStringConvertible {
    var description: String {
        switch self.kind {
        case .add:
            "+"
        case .subtract:
            "-"
        case .multiply:
            "*"
        case .divide:
            "/"
        }
    }
    
    let kind: OperatorKind
    let precedence: Int8
    let isLeftAssociative: Bool
}

enum OperatorKind {
    case add
    case subtract
    case multiply
    case divide
}

class PeekableString {
    var characters: [Character] = []
    var position: Int
    
    var isAtEnd: Bool {
        get {
            return position >= characters.count
        }
    }
    
    init(text: String) {
        self.position = 0
        for character in text {
            self.characters.append(character)
        }
    }
    
    func peek() -> Character? {
        if position >= characters.count {
            return Optional.none
        }
        
        return characters[position]
    }
    
    func next() {
        if position >= characters.count {
            return
        }
        
        position = position + 1
        return
    }
}

func tokenize(input: String) -> [Token] {
    var tokens: [Token] = []
    let stream = Peekable<String>(data: input)
    while !stream.isAtEnd {
        switch stream.peek() {
            case let .some(c):
                if "0"..."9" ~= c {
                    let number = parseInteger(stream: stream)
                    tokens.append(Token.integer(number))
                }
                else if c == "+" {
                    tokens.append(Token.op(Operator.init(kind: OperatorKind.add, precedence: 2, isLeftAssociative: true)))
                    stream.next()
                }
                else if c == "-" {
                    tokens.append(Token.op(Operator.init(kind: OperatorKind.subtract, precedence: 2, isLeftAssociative: true)))
                    stream.next()
                }
                else if c == "*" {
                    tokens.append(Token.op(Operator.init(kind: OperatorKind.multiply, precedence: 3, isLeftAssociative: true)))
                    stream.next()
                }
                else if c == "/" {
                    tokens.append(Token.op(Operator.init(kind: OperatorKind.divide, precedence: 3, isLeftAssociative: true)))
                    stream.next()
                }
                else if c == "(" {
                    tokens.append(Token.lparen)
                    stream.next()
                }
                else if c == ")" {
                    tokens.append(Token.rparen)
                    stream.next()
                }
                else {
                    // Unknown character
                    stream.next()
                }
            case .none:
                break;
        }
    }
    
    return tokens
}

func parseInteger(stream: Peekable<String>) -> Int {
    var accumulator: [Character] = []
    loop: while !stream.isAtEnd {
        switch stream.peek() {
            case let .some(c):
                if c.isNumber {
                    accumulator.append(c)
                    stream.next()
                }
                else {
                    break loop
                }
                
            case .none:
                break loop
        }
    }
    
    return Int(String(accumulator)) ?? 0
}

enum ShuntingYardError: Error {
    case leftParenthesisMissing
}

func shuntingYard(tokens: [Token]) throws -> [Token] {
    var output: [Token] = []
    var stack: [Token] = []
    for token in tokens {
        switch token {
            case .integer(_):
                output.append(token)
            case .lparen:
                stack.insert(token, at: 0)
            case .rparen:
                var foundLeft = false
                loop: while !stack.isEmpty {
                    switch stack.first {
                        case .none:
                            break
                        case let .some(x):
                            switch x {
                                case .lparen:
                                    foundLeft = true
                                    break loop;
                                default:
                                    break;
                            }
                    }
                    
                    output.append(stack.remove(at: 0))
                }
            
                if !foundLeft {
                    throw ShuntingYardError.leftParenthesisMissing
                }
            
                stack.remove(at: 0)
            case let .op(op):
                // Rebalance the stack with consideration to operator precedence and associativeness.
                loop: while !stack.isEmpty {
                    let item = stack.last.unsafelyUnwrapped
                    let cond1 = item.isOperator() && item.getPrecedence() > op.precedence;
                    let cond2 = item.isOperator() && op.precedence == item.getPrecedence() && item.isLeftAssociative()
                    if cond1 || cond2 {
                        output.append(stack.remove(at: 0))
                    }
                    else {
                        break loop
                    }
                }
            
                // Push the current operator onto the stack.
                stack.insert(Token.op(op), at: 0)
        }
    }
    
    while !stack.isEmpty {
        output.append(stack.remove(at: 0))
    }
    
    return output
}
