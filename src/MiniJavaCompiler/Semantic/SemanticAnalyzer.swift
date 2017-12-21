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
    let idToken: Token!
    
    init(node: BaseASTNode) {
        self.idToken = node.token!
        self.identifier = idToken.text
    }
    
    init(identifier: String) {
        self.idToken = nil
        self.identifier = identifier
    }
}

class TypeDeclaration: BaseDeclaration {
    let isArray: Bool
    var typeToken: Token!
    
    
    override init(node: BaseASTNode) {
        let subNode = node[0]
        var idNode = subNode
        if subNode.desc == "Array Type" {
            self.isArray = true
            idNode = subNode[0]
        } else {
            self.isArray = false
        }
        if subNode.desc == "Identifier" {
            idNode = subNode[0]
        }
        super.init(node: idNode)
        typeToken = idNode.token
    }
    
    override init(identifier: String) {
        isArray = false
        typeToken = nil
        super.init(identifier: identifier)
    }
    
    static let VoidType = TypeDeclaration(identifier: "void")
}

class VariableDeclaration: BaseDeclaration {
    var type: TypeDeclaration
    
    override init(node: BaseASTNode) {
        let typeNode = node[0]
        let idNode = node[1][0]
        self.type = TypeDeclaration(node: typeNode)
        super.init(node: idNode)
    }
}

class MethodDeclaration: BaseDeclaration {
    var returnType: TypeDeclaration
    var arguments: [VariableDeclaration] = []
    var variables: [VariableDeclaration] = []
    var statementsNode: BaseASTNode?
    
    override init(node: BaseASTNode) {
        let returnTypeNode = node[0]
        returnType = TypeDeclaration(node: returnTypeNode)
        let idNode = node[1][0]
        super.init(node: idNode)
        let argumentNodes = node[2].children!
        arguments = argumentNodes.map { VariableDeclaration(node: $0) }
        let variableNodes = node[3].children!
        variables = variableNodes.map { VariableDeclaration(node: $0) }
        statementsNode = node[4]
    }
    
    override init(identifier: String) {
        returnType = TypeDeclaration.VoidType
        super.init(identifier: identifier)
    }
    
    static func MainMethodDeclaration(argumentsIdentifier: String) -> MethodDeclaration {
        let declaration = MethodDeclaration(identifier: "main")
        return declaration
    }
}

class ClassDeclaration: BaseDeclaration {
    var extends: String? = nil
    var variables: [VariableDeclaration] = []
    var methods: [MethodDeclaration] = []
    
    override init(node: BaseASTNode) {
        let idNode = node[0][0]
        super.init(node: idNode)
        let extendsNode = node[1]
        if extendsNode.children == nil {
            extends = nil
        } else {
            extends = extendsNode[0][0].token!.text
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
        let argsNodeTokenText = node[1][0].token!.text
        let mainMethodDeclaration = MethodDeclaration.MainMethodDeclaration(argumentsIdentifier: argsNodeTokenText)
        mainMethodDeclaration.statementsNode = node[2]
        declaration.methods = [mainMethodDeclaration]
        return declaration
    }
}

class SemanticAnalyzer {
    var mainClass: ClassDeclaration
    var classes: [ClassDeclaration] = []
    var classIds: [String] = []
    
    let reservedTypes = ["int", "boolean"]
    
    var success = true
    
    init(root: BaseASTNode) {
        // initialize classes with [MainClass]
        let mainClassNode = root[0]
        mainClass = ClassDeclaration.MainClassDeclaration(node: mainClassNode)
        
        let classNodes = root[1].children!
        classes = classNodes.map { ClassDeclaration(node: $0) }
        classIds = classes.map { $0.identifier }
    }
    
    func analyze() -> Bool {
        success = true
        // process extension - not implemented yet
        // type check: method return type, method arguments type, class variables and method variables type
        for `class` in classes {
            for variable in `class`.variables {
                verifyType(type: variable.type)
            }
            for method in `class`.methods {
                verifyType(type: method.returnType)
                for argument in method.arguments {
                    verifyType(type: argument.type)
                }
                for variable in method.variables {
                    verifyType(type: variable.type)
                }
            }
        }
        // check method statements
        return success
    }
    
    func verifyType(type: TypeDeclaration) {
        let id = type.identifier
        if !reservedTypes.contains(id) && !classIds.contains(id) {
            let info = "Unknown type \"\(id)\""
            let error = MJCError(code: UndeclaredTypeError, info: info, token: type.typeToken)
            error.print()
            success = false
        }
    }
}
