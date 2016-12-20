//
//  CombinationsTest.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/18.
//  Copyright © 2016年 Nycshisan. All rights reserved.
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
        let tokenizer = Tokenizer()
        let tokens = try! tokenizer.tokenize(material: material)
        let actual = PhraseParser(parser: parser).parse(tokens: tokens, pos: 0)
        if expected == nil {
            XCTAssertNil(actual)
        } else {
            XCTAssertNotNil(actual)
            XCTAssertTrue(actual!.data == expected!)
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
        let expected = ParseResult.Value(values: [ParseResult.Value(values: ["x", "y"])])
        expected.append(element: ParseResult.Value(value: "z"))
        let parser = idParser + idParser + idParser
        assertParseResultEqual(material: "x y z", parser: parser, expected: expected)
    }
    
    func testAlternate() {
        let parser = idParser | intParser | idParser
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
    
    func testLazy() {
        let parser = ~{ self.idParser }
        let expected = ParseResult.Value(value: "xx")
        assertParseResultEqual(material: "xx", parser: parser, expected: expected)
    }
    
    func testExp() {
        let parser = idParser * (ReservedParser(word: "+") ^ { return ASTNode(value: $0[0].value! + $0[2].value!) })
        var expected = ParseResult.Value(value: "x")
        assertParseResultEqual(material: "x", parser: parser, expected: expected)
        expected = ParseResult.Value(value: "xyz")
        assertParseResultEqual(material: "x + y +z", parser: parser, expected: expected)
    }
    
}
