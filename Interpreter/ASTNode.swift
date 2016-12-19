//
//  ASTNode.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

enum ASTNodeType {
    case Value
    case Array
    case None
}

class ASTNode: Expr {
    var value: String?
    var children: [ASTNode]?
    
    var type: ASTNodeType {
        get {
            if value != nil {
                return .Value
            }
            if children != nil {
                return .Array
            }
            return .None
        }
    }
    
    init(value: String?) {
        self.value = value
        self.children = nil
    }
    
    init(values: [ASTNode]) {
        self.value = nil
        self.children = values
    }
    
    init(_ anotherNode: ASTNode) {
        self.value = anotherNode.value
        self.children = anotherNode.children
    }
    
    subscript(index: Int) -> ASTNode {
        get {
            return children![index]
        }
        set {
            children![index] = newValue
        }
    }
    
    func append(element: ASTNode) {
        children!.append(element)
    }
    
    func eval(environment: inout [String : Any]) -> Any {
        fatalError("Base `ASTNode` class does not implement the `eval` function.")
    }
}

/* Base Parser Result Class */
class ParseResult {
    typealias Value = ASTNode
    
    var data: Value
    var pos: Int
    
    init(value: String?, pos: Int) {
        self.data = Value(value: value)
        self.pos = pos
    }
    
    init(values: [Value], pos: Int) {
        self.data = Value(values: values)
        self.pos = pos
    }
}
