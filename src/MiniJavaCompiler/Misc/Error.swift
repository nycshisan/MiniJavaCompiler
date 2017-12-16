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
let ExpectedUnconformityError: Int32 = 2
let TokenNotExhaustedError: Int32 = 3

class SCError: Error {
    static var material: String = ""
    
    let code: Int32
    let info: String
    let position: Int
    let lineNum: Int
    
    init(code: Int32, info: String, position: Int, lineNum: Int) {
        self.code = code
        self.info = info
        self.position = position
        self.lineNum = lineNum
        
        if SCError.material == "" {
            fatalError("Compile material for SCError class has not be initialized.")
        }
    }
    convenience init(code: Int32, info: String, token: Token) {
        self.init(code: code, info: info, position: token.position, lineNum: token.lineNum)
    }
    
    func print() {
        let line = SCError.material.components(separatedBy: "\n")[lineNum]
        Swift.print("Error: \(info) at line \(lineNum + 1):")
        Swift.print("\(line)")
        Swift.print(String(repeating: " ", count: position) + "^")
    }
}
