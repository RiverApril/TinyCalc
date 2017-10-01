//
//  Evaluator.swift
//  TinyCalc
//
//  Created by Braeden Atlee on 4/21/17.
//  Copyright © 2017 Braeden Atlee. All rights reserved.
//

import Cocoa

extension String: Error {}

protocol Symbol {
    
}

class Expression : Symbol{
    var symbols = [Symbol]()
    var parent: Expression? = nil
    
    func addNumber(_ number: String) {
        symbols.append(SymbolNumber(number))
    }
    
    func addExpression(_ exp: Expression) {
        exp.parent = self
        symbols.append(exp)
    }
    
    func addOperator(_ op: Character) {
        symbols.append(SymbolOperator(op))
    }
}

class SymbolNumber : Symbol{
    
    init(_ number: String){
        self.number = number
    }
    
    var number: String
}

class SymbolOperator : Symbol{
    
    init(_ op: Character){
        self.op = op
    }
    
    var op: Character
}

class SymbolFunction : Expression {
    
    init(name: String){
        self.name = name
    }
    
    var name: String
}

class Evaluator {
    
    static func evaluateOperatorHere(op: SymbolOperator, expression: Expression, initalI: Int) throws -> Int{
        var i = initalI
        if i > 0 && i < expression.symbols.count-1{
            if let left = expression.symbols[i-1] as? SymbolNumber, let right = expression.symbols[i+1] as? SymbolNumber{
                var result = 0.0
                if let l = Double(left.number), let r = Double(right.number){
                    switch op.op{
                    case "+":
                        result = l + r
                    case "-":
                        result = l - r
                    case "*":
                        result = l * r
                    case "/":
                        result = l / r
                        if(r == 0){
                            throw "Division by zero"
                        }
                    case "^":
                        result = pow(l, r)
                    case "%":
                        result = l.truncatingRemainder(dividingBy:r)
                        if(r == 0){
                            throw "Division by zero"
                        }
                    default:
                        throw "Unknown operator"
                    }
                    let num = SymbolNumber(String(result))
                    expression.symbols.remove(at: i-1) // remove the left
                    i -= 1 // move to stay on operator
                    expression.symbols.remove(at: i) // remove operator, now on right
                    expression.symbols[i] = num // change right to result
                }else{
                    throw "Number Invalid"
                }
            }else{
                throw "Operator lacking numbers"
            }
        }else{
            throw "Operator at edge"
        }
        return i
    }
    
    static func evaluateExpression(expression: Expression) throws -> SymbolNumber{
        
        if expression.symbols.count == 0{
            throw "Empty Expression"
        }
        
        // Evaluate (...)
        var i = 0
        while i < expression.symbols.count {
            if let exp = expression.symbols[i] as? Expression {
                try expression.symbols[i] = evaluateExpression(expression: exp)
            }
            i += 1
        }
        
        // Evaluate ^
        i = 0
        while i < expression.symbols.count {
            if let op = expression.symbols[i] as? SymbolOperator {
                if op.op == "^"{
                    try i = evaluateOperatorHere(op: op, expression: expression, initalI: i)
                }
            }
            i += 1
        }
        
        // Evaluate * and / and %
        i = 0
        while i < expression.symbols.count {
            if let op = expression.symbols[i] as? SymbolOperator {
                if op.op == "*" || op.op == "/" || op.op == "%"{
                    try i = evaluateOperatorHere(op: op, expression: expression, initalI: i)
                }
            }
            if i < expression.symbols.count-1 {
                if let left = expression.symbols[i] as? SymbolNumber, let right = expression.symbols[i+1] as? SymbolNumber {
                    if let l = Double(left.number), let r = Double(right.number) {
                        let result = l * r
                        let num = SymbolNumber(String(result))
                        expression.symbols.remove(at: i) // remove left number
                        expression.symbols[i] = num // set current number
                        i -= 1 // go left one
                    }
                }
            }
            i += 1
        }
        
        // Evaluate + and -
        i = 0
        while i < expression.symbols.count {
            if let op = expression.symbols[i] as? SymbolOperator {
                if op.op == "+" || op.op == "-"{
                    try i = evaluateOperatorHere(op: op, expression: expression, initalI: i)
                }
            }
            i += 1
        }
        
        if expression.symbols.count != 1{
            throw "Evaluation Failed to Reduce"
        }
        if !(expression.symbols[0] is SymbolNumber){
            throw "Evaluation Failed to Reduce to Number"
        }
        
        
        if let function = expression as? SymbolFunction {
            return try SymbolNumber(evaluateFunction(name: function.name, number: (expression.symbols[0] as! SymbolNumber).number))
        } else {
            return expression.symbols[0] as! SymbolNumber
        }
        
    }
    
    static func evaluateFunction(name: String, number: String) throws -> String {
        if let num = Double(number) {
            switch name {
            case "sin":
                return "\(sin(num))"
            case "cos":
                return "\(cos(num))"
            case "tan":
                return "\(tan(num))"
            case "asin":
                return "\(asin(num))"
            case "acos":
                return "\(acos(num))"
            case "atan":
                return "\(atan(num))"
            case "sinh":
                return "\(sinh(num))"
            case "cosh":
                return "\(cosh(num))"
            case "tanh":
                return "\(tanh(num))"
            case "asinh":
                return "\(asinh(num))"
            case "acosh":
                return "\(acosh(num))"
            case "atanh":
                return "\(atanh(num))"
            case "sqrt":
                return "\(sqrt(num))"
            case "cbrt":
                return "\(cbrt(num))"
            case "abs":
                return "\(abs(num))"
            case "floor":
                return "\(floor(num))"
            case "ceil":
                return "\(ceil(num))"
            case "round":
                return "\(round(num))"
            case "log":
                return "\(log10(num))"
            case "logb":
                return "\(log2(num))"
            case "ln":
                return "\(log(num))"
            default:
                return "Unknown function: \(name)"
            }
        } else {
            throw "Function Contents not Number"
        }
    }
    
    class ParseStatus {
        
        init(str: String) {
            self.str = str
        }
        
        func char(offset: Int = 0) -> Character{
            let index = str.index(str.startIndex, offsetBy: i+offset)
            return str[index]
        }
        
        var str: String
        var exp = Expression()
        var i = 0
    }
    
    static func parseExpression(input: String) throws -> Expression {
        
        let filteredInput = (input as NSString).replacingOccurrences(of: " ", with:"");
        
        let status = ParseStatus(str: filteredInput)
        
        while (status.i < status.str.characters.count) {
            let char = status.char()
            switch(char){
                case "-":
                    if status.exp.symbols.count > 0 {
                        if !(status.exp.symbols.last is SymbolOperator) {
                            try addOperator(status)
                            break
                        }
                    }
                    fallthrough
                case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ".":
                    try addNumber(status)
                case "+", "*", "/", "^", "%":
                    try addOperator(status)
                case "(":
                    let newExp = Expression()
                    status.exp.addExpression(newExp)
                    status.exp = newExp
                    status.i += 1
                case ")":
                    if let parent = status.exp.parent {
                        status.exp = parent
                    } else {
                        // Allow too many closing parentheses for ease of use
                        let newExp = Expression()
                        newExp.addExpression(status.exp);
                        status.exp = newExp;
                    }
                    status.i += 1
                default:
                    if char >= "a" && char <= "z" {
                        try addFunctionOrConstant(status)
                    } else {
                        throw "Unknown symbol: \"\(char)\""
                    }
            }
        }
        
        while(status.exp.parent != nil){
            status.exp = status.exp.parent!
        }
        
        if status.exp.symbols.isEmpty {
            throw ""
        }
        
        return status.exp
    }
    
    static func addNumber(_ status: ParseStatus) throws {
        
        var number = ""
        
        var building = true
        
        while (status.i < status.str.characters.count && building) {
            let char = status.char()
            switch(char) {
                case "-":
                    if number.isEmpty {
                        number.append(char)
                    } else {
                        building = false
                    }
                case ".":
                    if number.contains(".") {
                        throw "Unexpected \".\""
                    } else {
                        number.append(char)
                    }
                case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                    number.append(char)
                default:
                    building = false
            }
            if building {
                status.i += 1
            }
        }
        
        if number == "." {
            throw "Number Incomplete"
        }
        
        status.exp.addNumber(number)
    }
    
    static func addOperator(_ status: ParseStatus) throws {
        
        let char = status.char()
        switch(char) {
            case "+", "-", "*", "/", "%", "^":
                status.exp.addOperator(char)
            default:
                throw "Unknown Operator: \"\(char)\""
        }
        status.i += 1
        
    }
    
    static func addFunctionOrConstant(_ status: ParseStatus) throws {
        
        var name = ""
        
        var isFunc = false
        
        while (status.i < status.str.characters.count) {
            let char = status.char()
            if char >= "a" && char <= "z" {
                name.append(char)
                status.i += 1
            } else if char == "(" {
                isFunc = true
                break
            } else {
                isFunc = false
                break
            }
        }
        
        if isFunc {
            let newExp = SymbolFunction(name: name)
            status.exp.addExpression(newExp) 
            status.exp = newExp
        } else {
            var num = 0.0
            switch(name) {
                case "pi":
                    num = M_PI
                case "e":
                    num = M_E
                default:
                    throw "Unknown constant \"\(name)\""
            }
            status.exp.addNumber("\(num)")
        }
        
    }
    
    static func evaluate(input: String) throws -> String{
        let s = try evaluateExpression(expression: parseExpression(input: input)).number;
        if(s.hasSuffix(".0")){
            return String(s.characters.dropLast(2));
        }
        return s;
    }

}
