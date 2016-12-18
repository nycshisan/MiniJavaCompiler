//
//  CombinationsTest.swift
//  Interpreter
//
//  Created by 陈十三 on 2016/12/18.
//  Copyright © 2016年 陈十三. All rights reserved.
//

import XCTest

class CombinationsTest: XCTestCase {
    
    var idParser: Parser = TagParser(tag: .Id)
    var intParser: Parser = TagParser(tag: .Int)
    
    override func setUp() {
        
    }
    
    override func tearDown() {
        
    }
    
    func assertParseResultEqual(material: String, parser: Parser, expected: ParseResult.Value?) {
        let lexer = Lexer(material: material)
        try! lexer.lex()
        let actual = PhraseParser(parser: parser).parse(tokens: lexer.tokens, pos: 0)
        if expected == nil {
            XCTAssertNil(actual)
        } else {
            XCTAssertNotNil(actual)
            XCTAssertTrue(actual!.value == expected!)
        }
    }
    
    func testTag() {
        let expected = ParseResult.Value(value: "if")
        assertParseResultEqual(material: "if", parser: TagParser(tag: .Reserved), expected: expected)
    }
    
    func testReserved() {
        let expected = ParseResult.Value(value: "if")
        assertParseResultEqual(material: "if", parser: ReservedParser(word: "if"), expected: expected)
    }
    
    func testConcat() {
        let expected = ParseResult.Value(values: ["x", "y"])
        let parser = idParser + idParser
        assertParseResultEqual(material: "x y", parser: parser, expected: expected)
    }
    
    func testConcatAssociativity() {
        var expected = ParseResult.Value(value: ParseResult.Value(values: ["x", "y"]))
        XCTAssertTrue(expected.append(element: ParseResult.Value(value: "z")))
        let parser = idParser + idParser + idParser
        assertParseResultEqual(material: "x y z", parser: parser, expected: expected)
    }
    
    func testAlternate() {
        let parser = idParser | intParser
        var expected = ParseResult.Value(value: "123")
        assertParseResultEqual(material: "123", parser: parser, expected: expected)
        expected = ParseResult.Value(value: "asd")
        assertParseResultEqual(material: "asd", parser: parser, expected: expected)
    }
    
    func testOpt() {
        let parser = OptParser(parser: idParser)
        let expected = ParseResult.Value(value: "asd")
        assertParseResultEqual(material: "asd", parser: parser, expected: expected)
        assertParseResultEqual(material: "123", parser: parser, expected: nil)
    }
    
    func testRep() {
        let parser = RepParser(parser: idParser)
        let expected = ParseResult.Value(values: ["x", "y", "z"])
        assertParseResultEqual(material: "x y z", parser: parser, expected: expected)
    }
    
    func testProcess() {
        let parser = idParser ^ { ParseResult.Value(value: $0.value! + $0.value!) }
        let expected = ParseResult.Value(value: "xx")
        assertParseResultEqual(material: "x", parser: parser, expected: expected)
    }
    
    func testExp() {
        let parser = idParser * ReservedParser(word: "+")
        var expected = ParseResult.Value(values: ["x"])
        assertParseResultEqual(material: "x", parser: parser, expected: expected)
        expected = ParseResult.Value(values: ["x", "y", "z"])
        assertParseResultEqual(material: "x + y +z", parser: parser, expected: expected)
    }
    
}
