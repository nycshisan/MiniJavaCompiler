//
//  ConcreteASTNode.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2017/12/22.
//  Copyright © 2017年 Nycshisan. All rights reserved.
//

import Foundation

/* Statement Nodes */
class IfStmtASTNode: BaseASTNode {
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: .VoidType)
        
        let result = children![0].semanticCheck(env)
        if !result.type.isBool() {
            let error = MJCError(code: InvalidExpressionTypeError, info: "The condition of if statement should be boolean type, not \"\(result.type.toString())\"", token: result.token)
            error.print()
        }
        
        let _ = children![1].semanticCheck(env)
        let _ = children![2].semanticCheck(env)
        
        return outResult
    }
    
    override func emulateRun(_ env: EmulateEnvironment) -> EmulateResult {
        let outResult = EmulateResult()
        
        let exprResult = children![0].emulateRun(env)
        
        var selectedChildIndex: Int
        if exprResult.value as! Bool {
            selectedChildIndex = 1 // true part
        } else {
            selectedChildIndex = 2 // false part
        }
        
        let result = children![selectedChildIndex].emulateRun(env)
        if result.isReturnStatement {
            outResult.value = result.value
            outResult.isReturnStatement = true
        }
        
        return outResult
    }
}

class PrintStmtASTNode: BaseASTNode {
    var itemType: SemanticCheckResultType! = nil
    
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: .VoidType)
        
        let result = children![0].semanticCheck(env)
        itemType = result.type
        
        return outResult
    }
    
    override func emulateRun(_ env: EmulateEnvironment) -> EmulateResult {
        let outResult = EmulateResult()
        
        let result = children![0].emulateRun(env)
        switch itemType.identifier {
        case "int":
            print(result.value as! Int)
        case "boolean":
            print(result.value as! Bool)
        default:
            fatalError()
        }
        
        return outResult
    }
}

class AssignmentStmtASTNode: BaseASTNode {
    var signToken: Token! = nil
    
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: .VoidType)
        
        let leftResult = children![0].semanticCheck(env)
        let rightResult = children![1].semanticCheck(env)
        
        if leftResult.type != rightResult.type {
            let info = "Can't assign \"\(rightResult.type.toString())\" to \"\(leftResult.type.toString())\""
            let error = MJCError(code: InvalidExpressionTypeError, info: info, token: signToken)
            error.print()
        }
        
        return outResult
    }
    
    override func emulateRun(_ env: EmulateEnvironment) -> EmulateResult {
        let outResult = EmulateResult()
        
        let id = children![0][0].token!.text
        let result = children![1].emulateRun(env)
        setVar(id: id, value: result.value, env: env)
        
        return outResult
    }
    
    func setVar(id: String, value: Any, env: EmulateEnvironment) {
        if env.methodVars.keys.contains(id) {
            env.methodVars[id] = value
            return
        }
        if EmulateEnvironment.ClassesVars[env.crtClassName]!.keys.contains(id) {
            EmulateEnvironment.ClassesVars[env.crtClassName]![id] = value
            return
        }
        fatalError()
    }
}

class ReturnStmtASTNode: BaseASTNode {
    var returnReservedToken: Token! = nil
    
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: .VoidType)
        outResult.token = returnReservedToken
        outResult.isReturnStatement = true
        
        let result = children![0].semanticCheck(env)
        outResult.type = result.type
        let expectedReturnType = env.crtMethod.returnType
        if !result.type.equals(expectedReturnType) {
            let expectedReturnTypeString = expectedReturnType.identifier + (expectedReturnType.isArray ? "[]" : "")
            let actualReturnTypeString = result.type.toString()
            let info = "Return type should be \"\(expectedReturnTypeString)\", not \"\(actualReturnTypeString)\""
            let error = MJCError(code: InconsistentReturnTypeError, info: info, token: result.token)
            error.print()
        }
        
        return outResult
    }
    
    override func emulateRun(_ env: EmulateEnvironment) -> EmulateResult {
        let outResult = EmulateResult()
        
        let result = children![0].emulateRun(env)
        outResult.value = result.value
        outResult.isReturnStatement = true
        
        return outResult
    }
}

class RepStmtASTNode: BaseASTNode {
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: .VoidType)
        
        var index = 0, count = children!.count
        for statement in children! {
            let result = statement.semanticCheck(env)
            if result.isReturnStatement {
                if index != count - 1 {
                    let warn = MJCError(code: StatementsAfterReturnWarning, info: "Return statement should be the last of statements", token: result.token, level: "warn")
                    warn.print()
                }
                outResult.type = result.type
            }
            index += 1
        }
        
        return outResult
    }
    
    override func emulateRun(_ env: EmulateEnvironment) -> EmulateResult {
        let outResult = EmulateResult()
        
        if children == nil { return outResult }
        for statement in children! {
            let result = statement.emulateRun(env)
            if result.isReturnStatement {
                outResult.value = result.value
                outResult.isReturnStatement = true
                break
            }
        }
        
        return outResult
    }
}

/* Expression Nodes */
class MethodInvocationArgumentsASTNode: BaseASTNode {
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: .VoidType)
        
        for child in children! {
            let result = child.semanticCheck(env)
            outResult.argTypes.append(result.type)
            outResult.argTokens.append(result.token)
        }
        
        return outResult
    }
}

class MethodInvocationExprASTNode: BaseASTNode {
    var methodStmtsNode: BaseASTNode! = nil
    var methodArgIds: [String] = []
    var className: String! = nil
    var methodName: String! = nil
    
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: .VoidType)
        
        let exprResult = children![0].semanticCheck(env)
        if exprResult.type.isArray || exprResult.type.isInt() || exprResult.type.isBool() {
            let error = MJCError(code: InvalidExpressionTypeError, info: "Type \"\(exprResult.type.toString())\" has no methods", token: exprResult.token)
            error.print()
        } else {
            className = exprResult.type.toString()
            if let `class` = env.classes[exprResult.type.identifier] {
                let invokedMethodId = children![1][0].token!.text
                if `class`.methods.keys.contains(invokedMethodId) {
                    let method = `class`.methods[invokedMethodId]!
                    methodStmtsNode = method.statementsNode!
                    methodName = method.identifier
                    let type = SemanticCheckResultType(identifier: method.returnType.identifier, isArray: method.returnType.isArray)
                    outResult.type = type
                    
                    let methodArgs = method.arguments.values
                    let argsResult = children![2].semanticCheck(env)
                    let argTypes = argsResult.argTypes
                    
                    if methodArgs.count != argTypes.count {
                        let errorToken = argsResult.argTokens[min(methodArgs.count, argTypes.count - 1)]
                        let error = MJCError(code: InconsistentMethodArgumentTypeError, info: "Method \"\(exprResult.type.toString()).\(invokedMethodId)\" expects \(methodArgs.count) arguments, not \(argTypes.count)", token: errorToken)
                        error.print()
                    } else {
                        let count = methodArgs.count
                        for index in 0 ..< count {
                            let expectedType = method.argumentAt(index: index).type
                            if !(expectedType.identifier == argTypes[index].identifier && expectedType.isArray == argTypes[index].isArray) {
                                let info = "The \(index + 1)th argument of Method \"\(exprResult.type.toString()).\(invokedMethodId)\" should be \"\(expectedType.toString())\", not \"\(argTypes[index].toString())\""
                                let error = MJCError(code: InconsistentMethodArgumentTypeError, info: info, token: argsResult.argTokens[index])
                                error.print()
                            }
                            
                            methodArgIds.append(method.argumentAt(index: index).identifier)
                        }
                    }
                } else {
                    let error = MJCError(code: UndefinedMethodError, info: "Method \"\(exprResult.type.toString()).\(invokedMethodId)\" is not defined", token: children![1][0].token!)
                    error.print()
                }
            } else {
                let error = MJCError(code: InvalidExpressionTypeError, info: "Can't find type \"\(exprResult.type.toString())\"", token: exprResult.token)
                error.print()
            }
        }
        
        
        outResult.token = exprResult.token
        return outResult
    }
    
    override func emulateRun(_ env: EmulateEnvironment) -> EmulateResult {
        let outResult = EmulateResult()
        
        let inEnv = EmulateEnvironment()
        inEnv.crtClassName = className
        inEnv.initMethodVars(className: className, methodName: methodName)
        
        let argc = methodArgIds.count
        for index in 0 ..< argc {
            let argumentNode = children![2].children![index]
            let result = argumentNode.emulateRun(env)
            inEnv.methodArgs[methodArgIds[index]] = result.value
        }

        let result = methodStmtsNode.emulateRun(inEnv)
        outResult.value = result.value

        return outResult
    }
}

class IntLiteralASTNode: BaseASTNode {
    var literalToken: Token! = nil
    
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: .IntType)
        literalToken = children![0].token!
        outResult.token = literalToken
        return outResult
    }
    
    override func emulateRun(_ env: EmulateEnvironment) -> EmulateResult {
        let outResult = EmulateResult()
        outResult.value = Int(literalToken.text)
        return outResult
    }
}

class BoolLiteralASTNode: BaseASTNode {
    var literalToken: Token! = nil
    
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: .BoolType)
        literalToken = children![0].token!
        outResult.token = literalToken
        return outResult
    }
    
    override func emulateRun(_ env: EmulateEnvironment) -> EmulateResult {
        let outResult = EmulateResult()
        outResult.value = Bool(literalToken.text)
        return outResult
    }
}

class ThisLiteralASTNode: BaseASTNode {
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: SemanticCheckResultType(identifier: env.crtClass.identifier, isArray: false))
        outResult.token = children![0].token!
        return outResult
    }
}

class NewObjectExprASTNode: BaseASTNode {
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: .VoidType)
        
        let idToken = children![0][0].token!
        if !env.classes.keys.contains(idToken.text) {
            let error = MJCError(code: UndeclaredTypeError, info: "Class \"\(idToken.text)\" is not defined", token: idToken)
            error.print()
        }
        let type = SemanticCheckResultType(identifier: idToken.text, isArray: false)
        outResult.type = type
        
        outResult.token = idToken
        return outResult
    }
}

class BiOpASTNode: BaseASTNode {
    var operToken: Token! = nil
    
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: .VoidType)
        
        let leftResult = children![0].semanticCheck(env)
        let rightResult = children![2].semanticCheck(env)
        operToken = children![1].token!
        switch operToken.text {
        case "<":
            outResult.type = .BoolType
            if !(leftResult.type.isInt() && rightResult.type.isInt()) {
                printError(left: leftResult, right: rightResult)
            }
        case "+":
            fallthrough
        case "-":
            fallthrough
        case "*":
            outResult.type = .IntType
            if !(leftResult.type.isInt() && rightResult.type.isInt()) {
                printError(left: leftResult, right: rightResult)
            }
        case "&&":
            outResult.type = .BoolType
            if !(leftResult.type.isBool() && rightResult.type.isBool()) {
                printError(left: leftResult, right: rightResult)
            }
        default:
            fatalError()
        }
        
        outResult.token = leftResult.token
        return outResult
    }
    
    func printError(left: SemanticCheckResult, right: SemanticCheckResult) {
        let info = "Can't apply operator \"\(operToken.text)\" to type \"\(left.type.toString())\" and \"\(right.type.toString())\""
        let error = MJCError(code: InvalidExpressionTypeError, info: info, token: operToken)
        error.print()
    }
    
    override func emulateRun(_ env: EmulateEnvironment) -> EmulateResult {
        let outResult = EmulateResult()
        
        let leftResult = children![0].emulateRun(env)
        let rightResult = children![2].emulateRun(env)
        let leftValue = leftResult.value
        let rightValue = rightResult.value
        
        switch operToken.text {
        case "+":
            outResult.value = (leftValue as! Int) + (rightValue as! Int)
        case "-":
            outResult.value = (leftValue as! Int) - (rightValue as! Int)
        case "*":
            outResult.value = (leftValue as! Int) * (rightValue as! Int)
        case "<":
            outResult.value = (leftValue as! Int) < (rightValue as! Int)
        case "&&":
            outResult.value = (leftValue as! Bool) && (rightValue as! Bool)
        default:
            fatalError()
        }
        
        return outResult
    }
}

/* Identifier Node */
class IdentifierASTNode: BaseASTNode {
    var id: String! = nil
    
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: .VoidType)
        
        id = children![0].token!.text
        var variable: VariableDeclaration! = nil
        
        variable = env.crtMethod.variables[id] ?? env.crtMethod.arguments[id] ?? env.crtClass.variables[id]
        
        if variable != nil {
            let type = SemanticCheckResultType(identifier: variable.type.identifier, isArray: variable.type.isArray)
            outResult.type = type
        } else {
            let error = MJCError(code: UndeclaredVariableError, info: "Variable used before declaration", token: children![0].token!)
            error.print()
        }
        
        outResult.token = children![0].token!
        return outResult
    }
    
    override func emulateRun(_ env: EmulateEnvironment) -> EmulateResult {
        let outResult = EmulateResult()
        outResult.value = getVar(env)
        return outResult
    }
    
    func getVar(_ env: EmulateEnvironment) -> Any {
        if env.methodVars.keys.contains(id) {
            return env.methodVars[id]!
        }
        if env.methodArgs.keys.contains(id) {
            return env.methodArgs[id]!
        }
        if EmulateEnvironment.ClassesVars[env.crtClassName]!.keys.contains(id) {
            return EmulateEnvironment.ClassesVars[env.crtClassName]![id]!
        }
        fatalError()
    }
}
