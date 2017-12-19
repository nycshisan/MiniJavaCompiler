//
//  TokenizerTest.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/18.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

import Foundation
import XCTest

extension Token: Equatable {
    static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.text == rhs.text && lhs.tag == rhs.tag
    }
}

class TokenizerTest: XCTestCase {
    func assertTokenEqual(material: String, expected: [Token]) {
        let tokenizer = Tokenizer()
        let actual = tokenizer.forceTokenize(material: material)
        XCTAssertEqual(actual, expected)
    }
    
    func testEmpty() {
        assertTokenEqual(material: "", expected: [])
    }
    
    func testSpaceAndComment() {
        assertTokenEqual(material: "  //some comment\n  ", expected: [])
    }
    
    func testInt() {
        assertTokenEqual(material: "123\n-456", expected: [Token(text: "123", tag: .Int), Token(text: "-456", tag: .Int)])
    }
    
    func testId() {
        assertTokenEqual(material: "someId another_Id", expected: [Token(text: "someId", tag: .Id), Token(text: "another_Id", tag: .Id)])
    }
    
    func testReservedWords() {
        for word in ReservedWords {
            assertTokenEqual(material: word, expected: [Token(text: word, tag: .Reserved)])
        }
    }
    
    func testOperatorsAndDelimiters() {
        let opers = "+ - * && ! = < [ ] { } , ( ) ;".components(separatedBy:
            CharacterSet(charactersIn: " "))
        for oper in opers {
            assertTokenEqual(material: oper, expected: [Token(text: oper, tag: .Reserved)])
        }
    }
}
