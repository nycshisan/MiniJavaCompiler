//
//  SemanticActions.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2017/12/17.
//  Copyright © 2017年 Nycshisan. All rights reserved.
//

import Foundation

typealias SemanticAction = (BaseASTNode) -> BaseASTNode

class SemanticActionFactory {
    // Construct an action that makes the input node to be wrapped(fathered) by a null node
    // whose description is the construction argument
    static func WrapAction(description: String) -> SemanticAction {
        let action: SemanticAction = {
            (inNode: BaseASTNode) in
            let outNode = BaseASTNode(children: [inNode], pos: inNode.pos)
            outNode.desc = description
            return outNode
        }
        return action
    }
    
    // Construct an action that simply fill the description
    static func DescAction(description: String) -> SemanticAction {
        let action: SemanticAction = {
            (inNode: BaseASTNode) in
            inNode.desc = description
            return inNode
        }
        return action
    }
}

let IdleAction: SemanticAction = {
    (inNode: BaseASTNode) in
    return inNode
}

let MainCLassAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children = [inNode[1], inNode[11], inNode[13]]
//    inNode[0].desc = "Main Class Identifier"
//    inNode[1].desc = "Main Function Arguments Identifier"
//    inNode[2].desc = "Main Function Statements"
    return inNode
}

let ClassDeclarationAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children = [inNode[1], inNode[2], inNode[4], inNode[5]]
    inNode[1].desc = "Extends"
    return inNode
}

let VarDeclarationAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children!.removeLast()
    return inNode
}

let MethodDeclarationArgumentsAction: SemanticAction = {
    (inNode: BaseASTNode) in
    for child in inNode.children! {
        child.desc = "Argument"
    }
    return inNode
}

let MethodDeclarationAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children = [inNode[1], inNode[2], inNode[3], inNode[5], inNode[6]]
    return inNode
}

let IntArrayTypeAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children = []
    return inNode
}

let IfStmtAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children = [inNode[1], inNode[2], inNode[4]]
    return inNode
}

let WhileStmtAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children!.removeFirst()
    return inNode
}

let PrintStmtAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children = [inNode[1]]
    return inNode
}

let AssignmentStmtAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children = [inNode[0], inNode[2]]
    return inNode
}

let SubscriptAssignmentStmtAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children = [inNode[0], inNode[2], inNode[5]]
    return inNode
}

let ReturnStmtAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children = [inNode[1]]
    return inNode
}

let SubscriptExprAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children = [inNode[0], inNode[2]]
    return inNode
}

let LengthExprAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children = [inNode[0]]
    return inNode
}

let MethodInvocationArgumentsAction: SemanticAction = {
    (inNode: BaseASTNode) in
    if inNode.children!.count == 1 && inNode[0].children != nil && inNode[0].children!.count == 0 && inNode[0].desc == "Nil" {
        inNode.children = []
    }
    return inNode
}

let MethodInvocationExprAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children = [inNode[0], inNode[2], inNode[4]]
    return inNode
}

let NewObjectAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children = [inNode[1]]
    return inNode
}

let NewIntArrayAction: SemanticAction = {
    (inNode: BaseASTNode) in
    inNode.children = [inNode[1], inNode[3]]
    return inNode
}

let GroupAction: SemanticAction = {
    (inNode: BaseASTNode) in
    let outNode = inNode[1]
    outNode.pos = inNode[2].pos
    return outNode
}

let BiOpAction: SemanticAction = {
    (inNode: BaseASTNode) in
    if inNode.children!.count == 1 {
        return inNode[0]
    }
    if inNode.children!.count != 0 {
        inNode.desc = "Binary Operator Expression"
    }
    return inNode
}