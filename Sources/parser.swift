indirect enum Expression : CustomStringConvertible {
    var description: String {
        switch self {
        case let .add(left, right):
            "\(left)+\(right)"
        case let .subtract(left, right):
            "\(left)-\(right)"
        case let .multiply(left, right):
            "\(left)*\(right)"
        case let .divide(left, right):
            "\(left)/\(right)"
        case let .integer(value):
            String(value)
        }
    }
    
    case add(Expression, Expression)
    case subtract(Expression, Expression)
    case multiply(Expression, Expression)
    case divide(Expression, Expression)
    case integer(Int)
    
    func Accept(visitor: Visitor) -> Int {
        switch self {
        case let .add(left, right):
            return visitor.visitAdd(left: left, right: right)
        case let .subtract(left, right):
            return visitor.visitSubtract(left: left, right: right)
        case let .multiply(left, right):
            return visitor.visitMultiply(left: left, right: right)
        case let .divide(left, right):
            return visitor.visitDivide(left: left, right: right)
        case let .integer(value):
            return value
        }
    }
}

protocol Visitor {
    func visitAdd(left: Expression, right: Expression) -> Int
    func visitSubtract(left: Expression, right: Expression) -> Int
    func visitMultiply(left: Expression, right: Expression) -> Int
    func visitDivide(left: Expression, right: Expression) -> Int
}

struct Evaluator : Visitor {
    func visitAdd(left: Expression, right: Expression) -> Int {
        return left.Accept(visitor: self) + right.Accept(visitor: self)
    }
    
    func visitSubtract(left: Expression, right: Expression) -> Int {
        return left.Accept(visitor: self)  - right.Accept(visitor: self)
    }
    
    func visitMultiply(left: Expression, right: Expression) -> Int {
        return left.Accept(visitor: self)  * right.Accept(visitor: self)
    }
    
    func visitDivide(left: Expression, right: Expression) -> Int {
        return left.Accept(visitor: self)  / right.Accept(visitor: self)
    }
}

func parse(input: String) -> Expression {
    let tokens = tokenize(input: input)
    return parse(tokens: tokens)
}

func parse(tokens: [Token]) -> Expression {
    var stack: [Expression] = []
    for token in tokens {
        switch token {
            case let .integer(value):
                stack.insert(Expression.integer(value), at: 0)
            case let .op(op):
                let right = stack.remove(at: 0)
                let left = stack.remove(at: 0)
                switch op.kind {
                    case .add:
                        stack.insert(Expression.add(left, right), at: 0)
                    case .subtract:
                        stack.insert(Expression.subtract(left, right), at: 0)
                    case .multiply:
                        stack.insert(Expression.multiply(left, right), at: 0)
                    case .divide:
                        stack.insert(Expression.divide(left, right), at: 0)
                }
            case .lparen:
                break
            case .rparen:
                break
        }
    }
    
    return stack.remove(at: 0)
}
