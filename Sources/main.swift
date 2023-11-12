let args = CommandLine.arguments
if args.count < 2 {
    print("USAGE:")
    print("  swiftcalc <EXPR>")
    exit(1)
}

// Parse
let tokens = tokenize(input: args[1])
let tokens2 = try shuntingYard(tokens: tokens)
let expr = parse(tokens: tokens2)

// Evaluate
let result = expr.Accept(visitor: Evaluator())
print(result)
