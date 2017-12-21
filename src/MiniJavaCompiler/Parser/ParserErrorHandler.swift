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
    
    var maxPos = 0
    var maxPosExpected: [String] = []
    
    func addMaxPosExpected(value: AtomParseResultValue, pos: Int) {
        let valueString = value.parseErrorDisplayValue
        if pos >= maxPos {
            if pos > maxPos {
                maxPos = pos
                maxPosExpected = []
            }
            if !maxPosExpected.contains(valueString) {
                maxPosExpected.append(valueString)
            }
        }
    }
    
    func displayMaxPosExpected(tokens: [Token]) {
        let token = tokens[maxPos]
        let info = "Expected [\(maxPosExpected.joined(separator: ", "))], not \"\(token.text)\""
        let error = SCError(code: ExpectedUnconformityError, info: info, token: token)
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
