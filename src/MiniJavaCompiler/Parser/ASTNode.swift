//
//  ASTNode.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

/* Base Abstract Syntax Tree Node */
class BaseASTNode {
    var desc: String = "Nil Desc"
    
    var token: Token?
    var pos: Int // The position of next parsing token
    var children: [BaseASTNode]?
    
    init(token: Token?, pos: Int) {
        self.token = token
        self.pos = pos
        self.children = nil
    }
    
    init(children: [BaseASTNode]?, pos: Int) {
        self.token = nil
        self.pos = pos
        self.children = children
    }
    
    subscript(index: Int) -> BaseASTNode {
        get {
            assert(children != nil)
            return children![index]
        }
        set {
            assert(children != nil)
            children![index] = newValue
        }
    }
    
    func append(_ element: BaseASTNode) {
        assert(children != nil)
        children!.append(element)
    }
    
    func flatten() -> [BaseASTNode] {
        if self.token != nil {
            return [self]
        } else if self.children != nil {
            var result: [BaseASTNode] = []
            for child in self.children! {
                result += child.flatten()
            }
            return result
        } else {
            fatalError("unknown type AST node")
        }
    }
}
