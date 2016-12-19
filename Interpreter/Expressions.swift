//
//  Expressions.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/18.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

/* Base Expression protocol */
protocol Expr {
    func eval(environment: inout [String: Any]) -> Any
}

/* Base Class of Arithmetic Expressions */
class ArithExpr: ASTNode {}

/* Arithmetic Expressions */
class IntExpr: ArithExpr {
    override func eval(environment: inout [String: Any]) -> Any {
        return Int(value!)!
    }
}

class VarExpr: ArithExpr {
    // Expressions for variables
    override func eval(environment: inout [String: Any]) -> Any {
        return environment[value!]!
    }
}

class ArithBiOpExpr: ArithExpr {
    // Expressions for binary operators
    let left, right: ArithExpr
    let oper: String
    
    init(oper: String, left: ArithExpr, right: ArithExpr) {
        self.oper = oper
        self.left = left
        self.right = right
        super.init(value: nil)
    }
    
    override func eval(environment: inout [String : Any]) -> Any {
        let operFunc = environment[oper] as! (Any, Any) -> Any
        
        return operFunc(left.eval(environment: &environment), right.eval(environment: &environment))
    }
}
/*
/* Base Class of Bool Expressions */
class BoolExpr: ASTNode {}

/* Bool Expressions */
class RelOpExpr: BoolExpr {
    // Expressions for relationship operators
    let left, right: ArithExpr
    let oper: String
    
    init(oper: String, left: ArithExpr, right: ArithExpr) {
        self.oper = oper
        self.left = left
        self.right = right
    }
}

class BoolBiOpExpr: BoolExpr {
    // Expressions for bool operators
    let left, right: BoolExpr
    let oper: String
    
    init(oper: String, left: BoolExpr, right: BoolExpr) {
        self.oper = oper
        self.left = left
        self.right = right
    }
}

class NotExpr: BoolExpr {
    // Expressions for NOT operators
    let expr: BoolExpr
    
    init(expr: BoolExpr) {
        self.expr = expr
    }
}

/* Base Class of Statement Expressions */
class StmtExpr: ParseResult {}

/* Statement Expressions */
class AssignExpr: StmtExpr {
    // Expressions for assign statements
    let id: String
    let expr: ArithExpr
    
    init(id: String, expr: ArithExpr) {
        self.id = id
        self.expr = expr
    }
}

class CompExpr: StmtExpr {
    // Expressions for compound statements
    let exprs: [StmtExpr]
    
    init(exprs: [StmtExpr]) {
        self.exprs = exprs
    }
}

class IfExpr: StmtExpr {
    // Expressions for condition statements
    let trueStmt, falseStmt: StmtExpr
    
    init(trueStmt: StmtExpr, falseStmt: StmtExpr) {
        self.trueStmt = trueStmt
        self.falseStmt = falseStmt
    }
}

class WhileExpr: StmtExpr {
    // Expression for while loop statements
    let condition: BoolExpr
    let body: StmtExpr
    
    init(condition: BoolExpr, body: StmtExpr) {
        self.condition = condition
        self.body = body
    }
}
*/
