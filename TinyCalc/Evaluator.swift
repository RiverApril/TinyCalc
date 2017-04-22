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
    
    static func evaluateFunction(expression: Expression) throws -> SymbolNumber{
        if expression.symbols.count >= 1{
            if let fun = expression.symbols[0] as? SymbolFunction{
                
                expression.symbols.remove(at: 0)
                
                var result: Double? = nil
                
                if expression.symbols.count == 0{
                    if fun.name == "pi"{
                        result = Double.pi
                    }else if fun.name == "e"{
                        result = exp(1)
                    }
                }else if expression.symbols.count == 1{
                    if let symA = expression.symbols[0] as? SymbolNumber{
                        let a = Double(symA.number)!
                        if fun.name == "abs"{
                            result = a > 0 ? a : -a
                        }else if fun.name == "cos"{
                            result = cos(a)
                        }else if fun.name == "sin"{
                            result = sin(a)
                        }else if fun.name == "tan"{
                            result = tan(a)
                        }else if fun.name == "cosh"{
                            result = cosh(a)
                        }else if fun.name == "sinh"{
                            result = sinh(a)
                        }else if fun.name == "tanh"{
                            result = tanh(a)
                        }else if fun.name == "acos"{
                            result = acos(a)
                        }else if fun.name == "asin"{
                            result = asin(a)
                        }else if fun.name == "atan"{
                            result = atan(a)
                        }else if fun.name == "acosh"{
                            result = acosh(a)
                        }else if fun.name == "asinh"{
                            result = asinh(a)
                        }else if fun.name == "atanh"{
                            result = atanh(a)
                        }else if fun.name == "ln"{
                            result = log(a)
                        }else if fun.name == "log"{
                            result = log10(a)
                        }else if fun.name == "sqrt"{
                            result = sqrt(a)
                        }else{
                            throw "Unknown function"
                        }
                    }else{
                        throw "Function does not contain a number"
                    }
                }else if expression.symbols.count == 2{
                    if let symA = expression.symbols[0] as? SymbolNumber, let symB = expression.symbols[0] as? SymbolNumber{
                        let a = Double(symA.number)!
                        let b = Double(symB.number)!
                        if fun.name == "atan"{
                            result = atan2(a, b)
                        }else{
                            throw "Unknown function"
                        }
                    }else{
                        throw "Function does not contain a number"
                    }
                }
                
                if result == nil && expression.symbols.count >= 2{
                    var params = [Double]()
                    for sym in expression.symbols{
                        params.append(Double((sym as! SymbolNumber).number)!)
                    }
                    if fun.name == "min"{
                        result = params[0]
                        for param in params{
                            result = param < result! ? param : result!
                        }
                    }
                    if fun.name == "max"{
                        result = params[0]
                        for param in params{
                            result = param > result! ? param : result!
                        }
                    }
                    if fun.name == "minabs"{
                        result = params[0]
                        for param in params{
                            result = abs(param) < abs(result!) ? param : result!
                        }
                    }
                    if fun.name == "maxabs"{
                        result = params[0]
                        for param in params{
                            result = abs(param) > abs(result!) ? param : result!
                        }
                    }
                    if fun.name == "mean"{
                        result = 0
                        for param in params{
                            result! += param
                        }
                        result! /= Double(params.count)
                    }
                }
                
                if let res = result {
                    return SymbolNumber(number: String(res))
                }else{
                    throw "Unknown Function"
                }
                
            }else{
                throw "this isn't a function"
            }
        }else{
            throw "function too short"
        }
        
    }
    
    static func evaluateOperatorHere(op: SymbolOperator, expression: Expression, initalI: Int) throws -> Int{
        var i = initalI
        if i > 0 && i < expression.symbols.count-1{
            if let left = expression.symbols[i-1] as? SymbolNumber, let right = expression.symbols[i+1] as? SymbolNumber{
                var result = 0.0
                switch op.op{
                case "+":
                    result = Double(left.number)! + Double(right.number)!
                    break
                case "-":
                    result = Double(left.number)! - Double(right.number)!
                    break
                case "*":
                    result = Double(left.number)! * Double(right.number)!
                    break
                case "/":
                    result = Double(left.number)! / Double(right.number)!
                    break
                case "^":
                    result = pow(Double(left.number)!, Double(right.number)!)
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
                throw "Operator does not have numbers next to it"
            }
        }else{
            throw "Operator at edge of expression"
        }
        return i
    }
    
    static func evaluateExpression(expression: Expression) throws -> SymbolNumber{
        
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
        
        // Evaluate * and /
        i = 0
        while i < expression.symbols.count {
            if let op = expression.symbols[i] as? SymbolOperator {
                if op.op == "*" || op.op == "/"{
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
        
        if expression.symbols.count == 0{
            throw "evaluation error"
        }
        if expression.symbols.count >= 1{
            if expression.symbols[0] is SymbolFunction{
                return try evaluateFunction(expression: expression)
            }else if expression.symbols.count >= 2{
                throw "evaluation error"
            }
        }
        if !(expression.symbols[0] is SymbolNumber){
            throw "evaluation error"
        }
        
        return expression.symbols[0] as! SymbolNumber
        
    }
    
    static func parseExpression(input: String) throws -> Expression {
        
        let filteredInput = input.replacingOccurrences(of: " ", with: "")
        
        var exp = Expression()
        
        var buildingNumber: String = ""
        var buildingFunctionName: String = ""
        var justAddedValue = false
        var justClosedExpression = false
        
        for c in filteredInput.characters {
            
            switch c{
            case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9":
                buildingNumber.append(c)
                continue
            case ".":
                if buildingNumber.contains(".") {
                    throw "Number contains too many decimal places"
                } else {
                    buildingNumber.append(".")
                }
                continue
            default:
                if c == "-" {
                    if buildingNumber.isEmpty && justClosedExpression == false && justAddedValue == false {
                        exp.addNumber(number: "-1")
                        exp.addOperator(op: "*")
                        continue
                    }
                }
                if !buildingNumber.isEmpty{
                    if buildingNumber.characters.count == 1 && (buildingNumber == ".") {
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
            
            if(c >= "a" && c <= "z"){
                buildingFunctionName.append(c)
                continue
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
                if !buildingFunctionName.isEmpty{
                    exp.addFunction(name: buildingFunctionName)
                    buildingFunctionName = ""
                }
                continue
            case ")":
                if !justAddedValue{
                    throw "Unexpected closing paranthesis"
                }
                if let parent = exp.parent {
                    exp = parent
                }else{
                    throw "Too many closing parantheses"
                }
                justAddedValue = true
                justClosedExpression = true
                continue
            case "+", "-", "*", "/", "^":
                if !justAddedValue{
                    throw "Unexpected operator"
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
                throw "Unknown Symbol"
            }
            
        }
        if !buildingNumber.isEmpty{
            if buildingNumber.characters.count == 1 && (buildingNumber == ".") {
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
