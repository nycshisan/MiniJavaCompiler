//
//  SemanticAnalyzer.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2017/12/21.
//  Copyright © 2017年 Nycshisan. All rights reserved.
//

import Foundation

class BaseDeclaration {
    let identifier: String
    
    init(node: BaseASTNode) {
        self.identifier = node.token!.text
    }
    
    init(identifier: String) {
        self.identifier = identifier
    }
}

class TypeDeclaration: BaseDeclaration {
    var isArray = false
    
    override init(node: BaseASTNode) {
        let subNode = node[0]
        var idNode = subNode
        if subNode.desc == "Array Type" {
            self.isArray = true
            idNode = subNode[0]
        }
        super.init(node: idNode)
    }
    
    override init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    static let VoidType = TypeDeclaration(identifier: "void")
}

class VariableDeclaration: BaseDeclaration {
    var type: TypeDeclaration
    
    override init(node: BaseASTNode) {
        let typeNode = node[0]
        let idNode = node[1]
        self.type = TypeDeclaration(node: typeNode)
        super.init(node: idNode)
    }
}

class MethodDeclaration: BaseDeclaration {
    var returnType: TypeDeclaration
    var arguments: [VariableDeclaration] = []
    var variables: [VariableDeclaration] = []
    
    override init(node: BaseASTNode) {
        let returnTypeNode = node[0]
        self.returnType = TypeDeclaration(node: returnTypeNode)
        let idNode = node[1]
        super.init(node: idNode)
        let argumentNodes = node[2].children!
        arguments = argumentNodes.map { VariableDeclaration(node: $0) }
        let variableNodes = node[3].children!
        variables = variableNodes.map { VariableDeclaration(node: $0) }
    }
}

class ClassDeclaration: BaseDeclaration {
    var extends: ClassDeclaration?
    var variables: [VariableDeclaration] = []
    var methods: [MethodDeclaration] = []
    
    override init(node: BaseASTNode) {
        let idNode = node[0]
        super.init(node: idNode)
        let extendsNode = node[1]
        if extendsNode.children == nil {
            extends = nil
        } else {
            // not support extends yet
        }
        let variableNodes = node[2].children!
        variables = variableNodes.map { VariableDeclaration(node: $0) }
        let methodNodes = node[3].children!
        methods = methodNodes.map { MethodDeclaration(node: $0) }
    }
    
    override init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    static func MainClassDeclaration(node: BaseASTNode) -> ClassDeclaration {
        let declaration = ClassDeclaration(identifier: node[0][0].token!.text)
    }
}

class SemanticAnalyzer {
    var classes: [ClassDeclaration] = []
    
    func load(root: BaseASTNode) {
        // initialize classes with [MainClass]
//        let mainClassNode = root[0]
//
//        mainClass.methods = [mainMethod]
//        classes = [mainClass]
//        //
//        let classNodes = root[1].children!
//        for node in classNodes {
//
//        }
        
    }
    
    func analyze() -> Bool {
        return true
    }
}
