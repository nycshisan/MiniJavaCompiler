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
            let error = MJCError(code: InvalidExpressionTypeError, info: "The condition of if statement should be boolean type, not \(result.type.toString())", token: result.token)
            error.print()
        }
        
        let _ = children![1].semanticCheck(env)
        let _ = children![2].semanticCheck(env)
        
        return outResult
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
            let info = "Return type should be \(expectedReturnTypeString), not \(actualReturnTypeString)"
            let error = MJCError(code: InconsistentReturnTypeError, info: info, token: result.token)
            error.print()
        }
        
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
}

/* Expression Nodes */
class IntLiteralASTNode: BaseASTNode {
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: .IntType)
        outResult.token = children![0].token!
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
        
        
        return outResult
    }
    
    func printError(left: SemanticCheckResult, right: SemanticCheckResult) {
        let info = "Can't apply operator \"\(operToken.text)\" to type \"\(left.type.toString())\" and \"\(right.type.toString())\""
        let error = MJCError(code: InvalidExpressionTypeError, info: info, token: operToken)
        error.print()
    }
}

/* Identifier Node */
class IdentifierASTNode: BaseASTNode {
    var id: String! = nil
    
    override func semanticCheck(_ env: SemanticCheckResultEnvironment) -> SemanticCheckResult {
        let outResult = SemanticCheckResult(type: .VoidType)
        outResult.token = children![0].token!
        
        id = children![0].token!.text
        let variables = env.crtClass.variables + env.crtMethod.variables + env.crtMethod.arguments
        for variable in variables {
            if variable.identifier == id {
                let type = SemanticCheckResultType(type: variable.type.identifier, isArray: variable.type.isArray)
                outResult.type = type
                return outResult
            }
        }
        let error = MJCError(code: UndeclaredVariableError, info: "Variable used before declaration", token: outResult.token)
        error.print()
        
        return outResult
    }
}
