//
//  Expressions.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/18.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

/* Base Expression protocol */
protocol Expr {
    func eval(environment: inout [String: Any]) -> Any?
}

/* Arithmetic Expressions */
class IntExpr: ASTNode {
    var i: Int?
    
    override func eval(environment: inout [String: Any]) -> Any? {
//        if i == nil {
//            i = Int(value!)!
//        }
//        return i
        return Int(token!.text)!
    }
}

class VarExpr: ASTNode {
    // Expressions for variables
    override func eval(environment: inout [String: Any]) -> Any? {
        return environment[token!.text]!
    }
}

class BiOpExpr: ASTNode {
    // Expressions for binary operators
    override func eval(environment: inout [String : Any]) -> Any? {
        let left = self[0]
        let oper = self[1].token!.text
        let right = self[2]
        
        let operFunc = environment[oper] as! (Any, Any) -> Any
        
        return operFunc(left.eval(environment: &environment)!, right.eval(environment: &environment)!)
    }
}

class PreOpExpr: ASTNode {
    // Expressions for NOT operators
    override func eval(environment: inout [String : Any]) -> Any? {
        let oper = self[0].token!.text
        let operFunc = environment[oper] as! (Any) -> Any
        return operFunc(self[1].eval(environment: &environment)!)
    }
}

/* Statements */
class CompStmt: ASTNode {
    // Statements for compound statements
    override func eval(environment: inout [String : Any]) -> Any? {
        for stmt in children! {
            let _ = stmt.eval(environment: &environment)
        }
        return nil
    }
}

class AssignStmt: ASTNode {
    // Statements for assign statements
    override func eval(environment: inout [String : Any]) -> Any? {
        let id = self[0].token!.text
        let expr = self[1]
        environment[id] = expr.eval(environment: &environment)
        return nil
    }
}

class DeclStmt: ASTNode {
    // Statements for declaring a new variable
    override func eval(environment: inout [String : Any]) -> Any? {
        // todo
        return nil
    }
}

class IfStmt: ASTNode {
    // Statements for condition statements
    override func eval(environment: inout [String : Any]) -> Any? {
        let condition = self[0]
        let trueStmts = self[1]
        if condition.eval(environment: &environment) as! Bool {
            return trueStmts.eval(environment: &environment)
        } else {
            if self.children!.count == 3 {
                let falseStmts = self[2]
                return falseStmts.eval(environment: &environment)
            } else {
                return nil
            }
        }
    }
}

class WhileStmt: ASTNode {
    // Statements for while loop statements
    override func eval(environment: inout [String : Any]) -> Any? {
        let condition = self[0]
        let stmts = self[1]
        while condition.eval(environment: &environment) as! Bool {
            let _ = stmts.eval(environment: &environment)
        }
        return nil
    }
}

class PrintStmt: ASTNode {
    // Statements for printing
    override func eval(environment: inout [String : Any]) -> Any? {
        let expr = self[0]
        print(expr.eval(environment: &environment)!)
        return nil
    }
}
