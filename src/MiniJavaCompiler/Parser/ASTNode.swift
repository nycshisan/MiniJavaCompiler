//
//  ASTNode.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

enum ASTNodeType {
    case Token
    case Array
    case None
}

class ASTNode: Expr {
    var token: Token?
    var children: [ASTNode]?
    
    var type: ASTNodeType {
        get {
            if token != nil {
                return .Token
            }
            if children != nil {
                return .Array
            }
            return .None
        }
    }
    
    init(token: Token?) {
        self.token = token
        self.children = nil
    }
    
    init(children: [ASTNode]) {
        self.token = nil
        self.children = children
    }
    
    init(_ anotherNode: ASTNode) {
        self.token = anotherNode.token
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
    
    func append(_ element: ASTNode) {
        children!.append(element)
    }
    
    func eval(environment: inout [String : Any]) -> Any? {
        fatalError("Base `ASTNode` class does not implement the `eval` function.")
    }
}

/* Base Parser Result Class */
class ParseResult {
    typealias Node = ASTNode
    
    var node: Node
    var pos: Int
    
    init(token: Token?, pos: Int) {
        self.node = Node(token: token)
        self.pos = pos
    }
    
    init(children: [Node], pos: Int) {
        self.node = Node(children: children)
        self.pos = pos
    }
}
