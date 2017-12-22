//
//  Error.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2017/1/8.
//  Copyright © 2017年 Nycshisan. All rights reserved.
//

import Foundation

let UnknownError: Int32 = 555
let InvalidCharacterError: Int32 = 1
let TokenUnexpectedError: Int32 = 2
let TokenNotExhaustedError: Int32 = 3
let UndeclaredTypeError: Int32 = 4
let InconsistentReturnTypeError: Int32 = 5
let InvalidExpressionTypeError: Int32 = 6
let UndeclaredVariableError: Int32 = 7
let DuplicateDeclarationError: Int32 = 8
let UndefinedMethodError: Int32 = 9
let InconsistentMethodArgumentTypeError: Int32 = 10

let StatementsAfterReturnWarning: Int32 = 601

class MJCError: Error {
    static var material: String = ""
    
    let code: Int32
    let info: String
    let position: Int
    let lineNum: Int
    let level: String
    
    init(code: Int32, info: String, position: Int, lineNum: Int, level: String = "error") {
        self.code = code
        self.info = info
        self.position = position
        self.lineNum = lineNum
        self.level = level
        
        if MJCError.material == "" {
            fatalError("Compile material for SCError class has not be initialized.")
        }
    }
    convenience init(code: Int32, info: String, token: Token, level: String = "error") {
        self.init(code: code, info: info, position: token.position, lineNum: token.lineNum, level: level)
    }
    
    func print() {
        let line = MJCError.material.components(separatedBy: "\n")[lineNum]
        Swift.print("\(level.capitalized): \(info) at line \(lineNum + 1):")
        Swift.print("\(line)")
        Swift.print(String(repeating: " ", count: position) + "^")
    }
}
