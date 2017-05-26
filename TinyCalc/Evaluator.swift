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
    
    func addNumber(number: String) {
        symbols.append(SymbolNumber(number: number))
    }
    
    func addExpression(exp: Expression) {
        exp.parent = self
        symbols.append(exp)
    }
    
    func addOperator(op: String) {
        symbols.append(SymbolOperator(op: op))
    }
    
    func addFunction(name: String) {
        symbols.append(SymbolFunction(name: name))
    }
}

class SymbolNumber : Symbol{
    
    init(number: String){
        self.number = number
    }
    
    var number: String
}

class SymbolOperator : Symbol{
    
    init(op: String){
        self.op = op
    }
    
    var op: String
}

class SymbolFunction : Symbol{
    
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
                        break
                    case "-":
                        result = l - r
                        break
                    case "*":
                        result = l * r
                        break
                    case "/":
                        result = l / r
                        if(r == 0){
                            throw "Division by zero"
                        }
                        break
                    case "^":
                        result = pow(l, r)
                        break
                    case "%":
                        result = l.truncatingRemainder(dividingBy:r)
                        if(r == 0){
                            throw "Division by zero"
                        }
                        break
                    default:
                        throw "Unknown operator"
                    }
                    let num = SymbolNumber(number: String(result))
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
            throw ""
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
            throw "evaluation error"
        }
        if !(expression.symbols[0] is SymbolNumber){
            throw "evaluation error"
        }
        
        return expression.symbols[0] as! SymbolNumber
        
    }
    
    static func parseExpression(input: String) throws -> Expression {
        
        var filteredInput = (input as NSString).replacingOccurrences(of: "pi", with:"(\(M_PI))");
        filteredInput = (filteredInput as NSString).replacingOccurrences(of: "e", with:"(\(M_E))");
        
        var exp = Expression()
        
        var buildingNumber: String = ""
        var justAddedValue = false
        var justClosedExpression = false
        
        for c in filteredInput.characters {
            
            switch c{
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                buildingNumber.append(c)
                continue
            case ".":
                if buildingNumber.contains(".") {
                    throw "Too many '.'"
                } else {
                    buildingNumber.append(".")
                }
                continue
            default:
                if c == "-" {
                    if buildingNumber.isEmpty && exp.symbols.count >= 2 {
                        if let op = exp.symbols[exp.symbols.count-1] as? SymbolOperator{
                            if op.op == "^" || op.op == "/" || op.op == "*"{
                                buildingNumber.append("-")
                                continue
                            }
                        }
                    }
                    if buildingNumber.isEmpty && justClosedExpression == false && justAddedValue == false {
                        exp.addNumber(number: "-1")
                        exp.addOperator(op: "*")
                        continue
                    }
                }
                if !buildingNumber.isEmpty{
                    if buildingNumber.characters.count == 1 && (buildingNumber == "." || buildingNumber == "-") {
                        throw "Number incomplete"
                    }
                    if justClosedExpression {
                        exp.addOperator(op: "*")
                        justClosedExpression = false
                    }
                    exp.addNumber(number: buildingNumber)
                    buildingNumber = ""
                    justAddedValue = true
                }
                break
            }
            
            switch c{
            case "(":
                if justAddedValue || justClosedExpression{
                    exp.addOperator(op: "*")
                    justClosedExpression = false
                    justAddedValue = false
                }
                let newExp = Expression()
                exp.addExpression(exp: newExp)
                exp = newExp
                continue
            case ")":
                if exp.symbols.count > 0 && exp.symbols[exp.symbols.count-1] is SymbolOperator{
                    throw "Unexpected ')'"
                }
                if let parent = exp.parent {
                    exp = parent
                }else{
                    //throw "Too many ')'s"
                    let newExp = Expression()
                    newExp.addExpression(exp: exp);
                    exp = newExp;
                }
                justAddedValue = true
                justClosedExpression = true
                continue
            case "+", "-", "*", "/", "^", "%":
                if !justAddedValue{
                    throw "Unexpected operator: " + String(c)
                }else{
                    exp.addOperator(op: String(c))
                    justAddedValue = false
                    justClosedExpression = false
                }
                
                continue
            case ",":
                justAddedValue = false
                continue
            default:
                throw "Unknown Symbol: " + String(c)
            }
            
        }
        if !buildingNumber.isEmpty{
            if buildingNumber.characters.count == 1 && (buildingNumber == "." || buildingNumber == "-") {
                throw "Number incomplete"
            }
            if justClosedExpression {
                exp.addOperator(op: "*")
                justClosedExpression = false
            }
            exp.addNumber(number: buildingNumber)
            buildingNumber = ""
            justAddedValue = true
        }
        
        while let parent = exp.parent {
            exp = parent
        }
        
        return exp
    }
    
    static func evaluate(input: String) throws -> String{
        return try evaluateExpression(expression: parseExpression(input: input)).number
    }

}
