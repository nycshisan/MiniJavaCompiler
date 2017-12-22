//
//  ConcreteASTNode.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2017/12/22.
//  Copyright © 2017年 Nycshisan. All rights reserved.
//

import Foundation

/* Statement Nodes */
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
            let actualReturnTypeString = result.type.identifier + (result.type.isArray ? "[]" : "")
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
        let outResult = SemanticCheckResult(type: SemanticCheckResultType(type: "int", isArray: false))
        outResult.token = children![0].token!
        return outResult
    }
}
