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
    static func constructWrapAction(description: String) -> SemanticAction {
        let action: SemanticAction = {
            (inNode: BaseASTNode) in
            let outNode = BaseASTNode(children: [inNode], pos: inNode.pos)
            outNode.desc = description
            return outNode
        }
        return action
    }
    
    // Construct an action that simply fill the description
    static func constructDescAction(description: String) -> SemanticAction {
        let action: SemanticAction = {
            (inNode: BaseASTNode) in
            inNode.desc = description
            return inNode
        }
        return action
    }
}

let GroupAction: SemanticAction = {
    (inNode: BaseASTNode) in
    let innerNode = inNode[1]
    let outNode = BaseASTNode(children: [innerNode], pos: inNode.pos)
    outNode.desc = "Group"
    return outNode
}

let BiOpAction: SemanticAction = {
    (inNode: BaseASTNode) in
    if inNode.children!.count == 1 {
        return inNode[0]
    }
    inNode.desc = "Binary Operator"
    return inNode
}

let PreOpAction: SemanticAction = {
    (inNode: BaseASTNode) in
    guard let operToken = inNode[0].token else {
        return inNode[1]
    }
    inNode.desc = "Prefix Operator \(operToken.text)"
    return inNode
}
