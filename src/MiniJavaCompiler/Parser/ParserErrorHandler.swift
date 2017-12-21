//
//  ParserErrorHandler.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2017/12/20.
//  Copyright © 2017年 Nycshisan. All rights reserved.
//

import Foundation

class ParserErrorHandler {
    static let instance = ParserErrorHandler()
    
    private init() {}
    
    var MaxPos = 0
    var MaxPosExpected: [AtomParseResultValue] = []
    
    func AddMaxPosExpected(value: AtomParseResultValue, pos: Int) {
        if pos >= MaxPos {
            if pos > MaxPos {
                MaxPos = pos
                MaxPosExpected = []
            }
            MaxPosExpected.append(value)
        }
    }
    
    func DisplayMaxPosExpected(tokens: [Token]) {
        let token = tokens[MaxPos]
        let info = "Expected , not \"\(1)\""
        let error = SCError(code: ExpectedUnconformityError, info: info, token: tokens[MaxPos])
        error.print()
    }
}

protocol AtomParseResultValue {
    var parseErrorDisplayValue: String { get }
}
extension String: AtomParseResultValue {
    var parseErrorDisplayValue: String { return "\"\(self)\"" }
}
extension TokenTag: AtomParseResultValue {
    var parseErrorDisplayValue: String { return "\(self)" }
}
