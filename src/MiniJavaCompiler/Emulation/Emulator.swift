//
//  Emulator.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2017/12/22.
//  Copyright © 2017年 Nycshisan. All rights reserved.
//

import Foundation

class Emulator {
    let analyzer: SemanticAnalyzer
    let root: BaseASTNode
    
    init(analyzer: SemanticAnalyzer, root: BaseASTNode) {
        self.analyzer = analyzer
        self.root = root
    }
    
    func emulate() {
        let env = EmulateEnvironment()
        env.load(analyzer: analyzer)
        let _ = analyzer.mainClass.methods.values.first!.statementsNode!.emulateRun(env)
    }
}

class EmulateEnvironment {
    static var ClassesVars: [String: [String: Any]] = [:]
    var methodArgs: [String: Any] = [:]
    var methodVars: [String: Any] = [:]
    
    static var MethodVarType: [String: [String: [String: TypeDeclaration]]] = [:]
    
    var crtClassName: String! = nil
    
    func load(analyzer: SemanticAnalyzer) {
        for `class` in analyzer.classes.values {
            let className = `class`.identifier
            EmulateEnvironment.MethodVarType[className] = [:]
            EmulateEnvironment.ClassesVars[className] = [:]
            for variable in `class`.variables.values {
                initVar(id: variable.identifier, type: variable.type, target: &EmulateEnvironment.ClassesVars[className]!)
            }
            for method in `class`.methods.values {
                let methodName = method.identifier
                EmulateEnvironment.MethodVarType[className]![methodName] = [:]
                for variable in method.variables.values {
                    EmulateEnvironment.MethodVarType[className]![methodName]![variable.identifier] = variable.type
                }
            }
        }
    }
    
    func initMethodVars(className: String, methodName: String) {
        methodVars.removeAll(keepingCapacity: true)
        let prototypes = EmulateEnvironment.MethodVarType[className]![methodName]!
        for (id, type) in prototypes {
            initVar(id: id, type: type, target: &methodVars)
        }
    }
    
    func initVar(id: String, type: TypeDeclaration, target: inout [String: Any]) {
        switch type.identifier {
        case "int":
            if type.isArray {
                target[id] = Array<Int>()
            } else {
                target[id] = Int()
            }
        case "boolean":
            if type.isArray {
                target[id] = Array<Bool>()
            } else {
                target[id] = Bool()
            }
        default:
            fatalError()
        }
    }
}

class EmulateResult {
    var value: Any! = nil
    
    var isReturnStatement = false
}
