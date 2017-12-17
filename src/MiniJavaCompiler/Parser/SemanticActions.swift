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
    // Construct an action that simply make the input node to be wrapped(fathered) by a null node
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
    
    // Construct an action that flatten the input subtree to be the children of a null node
    // whose description is the construction argument
    static func constructFlattenAction(description: String) -> SemanticAction {
        let action: SemanticAction = {
            (inNode: BaseASTNode) in
            let outNode = BaseASTNode(children: inNode.flatten(), pos: inNode.pos)
            outNode.desc = description
            return outNode
        }
        return action
    }
}

let IntLiteralAction = SemanticActionFactory.constructWrapAction(description: "IntLiteral")

let IdentifierAction = SemanticActionFactory.constructWrapAction(description: "Identifier")
