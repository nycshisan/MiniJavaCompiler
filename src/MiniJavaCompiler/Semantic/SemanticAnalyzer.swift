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
    
    func toString() -> String {
        return identifier + (isArray ? "[]" : "")
    }
    
    static let VoidType = TypeDeclaration(identifier: "void")
}

final class VariableDeclaration: BaseDeclaration, MapableToPair {
    var type: TypeDeclaration
    
    override init(node: BaseASTNode) {
        let typeNode = node[0]
        let idNode = node[1][0]
        self.type = TypeDeclaration(node: typeNode)
        super.init(node: idNode)
    }
    
    static func MapToPair(node: BaseASTNode) -> (String, VariableDeclaration) {
        let declaration = VariableDeclaration(node: node)
        let id = declaration.identifier
        return (id, declaration)
    }
}

final class MethodDeclaration: BaseDeclaration, MapableToPair {
    var returnType: TypeDeclaration
    var arguments: [String: VariableDeclaration] = [:]
    var argumentIds: [String] = []
    var variables: [String: VariableDeclaration] = [:]
    var statementsNode: BaseASTNode?
    
    override init(node: BaseASTNode) {
        let returnTypeNode = node[0]
        returnType = TypeDeclaration(node: returnTypeNode)
        let idNode = node[1][0]
        super.init(node: idNode)
        let argumentNodes = node[2].children!
        argumentIds = MapToDict(array: argumentNodes, type: "argument", target: &arguments, keepOrder: true)!
        let variableNodes = node[3].children!
        let _ = MapToDict(array: variableNodes, type: "variable", target: &variables)
        statementsNode = node[4]
    }
    
    override init(identifier: String) {
        returnType = TypeDeclaration.VoidType
        super.init(identifier: identifier)
    }
    
    func argumentAt(index: Int) -> VariableDeclaration {
        return arguments[argumentIds[index]]!
    }
    
    static func MainMethodDeclaration(argumentsIdentifier: String) -> MethodDeclaration {
        let declaration = MethodDeclaration(identifier: "main")
        return declaration
    }
    
    static func MapToPair(node: BaseASTNode) -> (String, MethodDeclaration) {
        let declaration = MethodDeclaration(node: node)
        let id = declaration.identifier
        return (id, declaration)
    }
}

final class ClassDeclaration: BaseDeclaration, MapableToPair {
    var extends: String? = nil
    var variables: [String: VariableDeclaration] = [:]
    var methods: [String: MethodDeclaration] = [:]
    
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
        let _ = MapToDict(array: variableNodes, type: "variable", target: &variables)
        let methodNodes = node[3].children!
        let _ = MapToDict(array: methodNodes, type: "method", target: &methods)
    }
    
    override init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    static func MainClassDeclaration(node: BaseASTNode) -> ClassDeclaration {
        let declaration = ClassDeclaration(identifier: node[0][0].token!.text)
        let argsNodeTokenText = node[1][0].token!.text
        let mainMethodDeclaration = MethodDeclaration.MainMethodDeclaration(argumentsIdentifier: argsNodeTokenText)
        mainMethodDeclaration.statementsNode = node[2]
        declaration.methods[mainMethodDeclaration.identifier] = mainMethodDeclaration
        return declaration
    }
    
    static func MapToPair(node: BaseASTNode) -> (String, ClassDeclaration) {
        let declaration = ClassDeclaration(node: node)
        let id = declaration.identifier
        return (id, declaration)
    }
}

protocol MapableToPair {
    static func MapToPair(node: BaseASTNode) -> (String, Self)
}

func MapToDict<T: MapableToPair & BaseDeclaration>(array: [BaseASTNode], type: String, target: inout [String: T], keepOrder: Bool = false) -> [String]? {
    var order: [String] = []
    array.forEach {
        (node: BaseASTNode) in
        let (id, declaration) = T.MapToPair(node: node)
        if target.keys.contains(id) {
            let error = MJCError(code: DuplicateDeclarationError, info: "Duplicate declared \(type)", token: declaration.idToken)
            error.print()
        } else {
            if keepOrder {
                order.append(id)
            }
            target[id] = declaration
        }
    }
    return keepOrder ? order : nil
}

class SemanticAnalyzer {
    var mainClass: ClassDeclaration
    var classes: [String: ClassDeclaration] = [:]
    
    let reservedTypes = ["int", "boolean"]
    
    var success = true
    
    init(root: BaseASTNode) {
        // initialize classes with [MainClass]
        let mainClassNode = root[0]
        mainClass = ClassDeclaration.MainClassDeclaration(node: mainClassNode)
        
        let classNodes = root[1].children!
        let _ = MapToDict(array: classNodes, type: "class", target: &classes)
    }
    
    func analyze() -> Bool {
        success = true
        // process extension - not implemented yet
        // type check: method return type, method arguments type, class variables and method variables type
        for `class` in classes.values {
            for variable in `class`.variables.values {
                verifyType(type: variable.type)
            }
            for method in `class`.methods.values {
                verifyType(type: method.returnType)
                for argument in method.arguments.values {
                    verifyType(type: argument.type)
                }
                for variable in method.variables.values {
                    verifyType(type: variable.type)
                }
            }
        }
        // check method statements
        let env = SemanticCheckResultEnvironment(classes: classes)
        for `class` in classes.values {
            env.crtClass = `class`
            for method in `class`.methods.values {
                env.crtMethod = method
                let _ = method.statementsNode!.semanticCheck(env)
            }
        }
        env.crtClass = mainClass
        env.crtMethod = mainClass.methods.values.first!
        let _ = mainClass.methods.values.first!.statementsNode!.semanticCheck(env)
        return success
    }
    
    func verifyType(type: TypeDeclaration) {
        let id = type.identifier
        if !reservedTypes.contains(id) && !classes.keys.contains(id) {
            let info = "Unknown type \"\(id)\""
            let error = MJCError(code: UndeclaredTypeError, info: info, token: type.typeToken)
            error.print()
            success = false
        }
    }
}

class SemanticCheckResultType {
    let identifier: String
    let isArray: Bool
    
    init(type: String, isArray: Bool) {
        self.identifier = type
        self.isArray = isArray
    }
    
    func equals(_ aType: TypeDeclaration) -> Bool {
        return aType.identifier == identifier && aType.isArray == isArray
    }
    
    func isBool() -> Bool {
        return identifier == "boolean" && !isArray
    }
    
    func isInt() -> Bool {
        return identifier == "int" && !isArray
    }
    
    func toString() -> String {
        return identifier + (isArray ? "[]" : "")
    }
    
    static let VoidType = SemanticCheckResultType(type: "void", isArray: false)
    static let BoolType = SemanticCheckResultType(type: "boolean", isArray: false)
    static let IntType = SemanticCheckResultType(type: "int", isArray: false)
}

extension SemanticCheckResultType: Equatable {
    static func ==(lhs: SemanticCheckResultType, rhs: SemanticCheckResultType) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.isArray == rhs.isArray
    }
}

class SemanticCheckResult {
    var type: SemanticCheckResultType
    var token: Token! = nil
    
    var isReturnStatement = false
    
    var argTypes: [SemanticCheckResultType] = []
    var argTokens: [Token] = []
    
    init(type: SemanticCheckResultType) {
        self.type = type
    }
}

class SemanticCheckResultEnvironment {
    let classes: [String: ClassDeclaration]
    var crtClass: ClassDeclaration! = nil
    var crtMethod: MethodDeclaration! = nil
    
    init(classes: [String: ClassDeclaration]) {
        self.classes = classes
    }
}
