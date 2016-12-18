//
//  LexerTest.swift
//  Interpreter
//
//  Created by 陈十三 on 2016/12/18.
//  Copyright © 2016年 陈十三. All rights reserved.
//

import XCTest

extension Token: Equatable {
    static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.text == rhs.text && lhs.tag == rhs.tag
    }
}

class LexerTest: XCTestCase {
    
    override func setUp() {
        
    }
    
    override func tearDown() {
        
    }
    
    func assertTokenEqual(material: String, expected: [Token]) {
        let lexer = Lexer(material: material)
        try! lexer.lex()
        let actual = lexer.tokens
        XCTAssertEqual(actual, expected)
    }
    
    func testEmpty() {
        assertTokenEqual(material: "", expected: [])
    }
    
    func testId() {
        assertTokenEqual(material: "abc", expected: [Token(text: "abc", tag: .Id)])
    }
    
    func testReserved() {
        assertTokenEqual(material: "if", expected: [Token(text: "if", tag: .Reserved)])
    }
    
    func testSpace() {
        assertTokenEqual(material: " \n", expected: [])
    }
    
    func testIdSpace() {
        assertTokenEqual(material: "asd zxc", expected: [Token(text: "asd", tag: .Id), Token(text: "zxc", tag: .Id)])
    }
    
}
