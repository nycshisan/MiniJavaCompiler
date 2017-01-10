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
    
    func assertParseResultEqual(material: String, parser: Parser, expected: ParseResult.Node?) {
        let tokenizer = Tokenizer()
        let tokens = try! tokenizer.tokenize(material: material)
        let actual = parser.parse(tokens: tokens, pos: 0)
        if expected == nil {
            XCTAssertTrue(actual!.node.type == .None)
        } else {
            XCTAssertNotNil(actual)
            XCTAssertTrue(actual!.node == expected!)
        }
    }
    
    func testTag() {
        let expected = ParseResult.Node(token: Token(text: "if"))
        assertParseResultEqual(material: "if", parser: TagParser(tag: .Reserved), expected: expected)
    }
    
    func testReserved() {
        let expected = ParseResult.Node(token: Token(text: "if"))
        assertParseResultEqual(material: "if", parser: ReservedParser(word: "if"), expected: expected)
    }
    
    func testConcat() {
        let expected = ParseResult.Node(children: ["x", "y"])
        let parser = idParser + idParser
        assertParseResultEqual(material: "x y", parser: parser, expected: expected)
    }
    
    func testConcatAssociativity() {
        let expected = ParseResult.Node(children: [ParseResult.Node(children: ["x", "y"])])
        expected.append(ParseResult.Node(token: Token(text: "z")))
        let parser = (idParser + idParser) as Parser + idParser // I do not know why here the concatenation of the first two idParser must be cast to Parser, one of me and Swift compiler must be stupid
        assertParseResultEqual(material: "x y z", parser: parser, expected: expected)
    }
    
    func testAlternate() {
        let parser = idParser | intParser | idParser
        var expected = ParseResult.Node(token: Token(text: "123"))
        assertParseResultEqual(material: "123", parser: parser, expected: expected)
        expected = ParseResult.Node(token: Token(text: "asd"))
        assertParseResultEqual(material: "asd", parser: parser, expected: expected)
    }
    
    func testOpt() {
        let parser = OptParser(parser: idParser)
        let expected = ParseResult.Node(token: Token(text: "asd"))
        assertParseResultEqual(material: "asd", parser: parser, expected: expected)
        assertParseResultEqual(material: "123", parser: parser, expected: nil)
    }
    
    func testRep() {
        let parser = RepParser(parser: idParser)
        let expected = ParseResult.Node(children: ["x", "y", "z"])
        assertParseResultEqual(material: "x y z", parser: parser, expected: expected)
    }
    
    func testProcess() {
        let parser = idParser ^ { ParseResult.Node(token: Token(text: $0.token!.text + $0.token!.text)) }
        let expected = ParseResult.Node(token: Token(text: "xx"))
        assertParseResultEqual(material: "x", parser: parser, expected: expected)
    }
    
    func testLazy() {
        let parser = ~{ self.idParser }
        let expected = ParseResult.Node(token: Token(text: "xx"))
        assertParseResultEqual(material: "xx", parser: parser, expected: expected)
    }
    
    func testExp() {
        let parser = idParser * ReservedParser(word: "+")
        var expected = ParseResult.Node(children: ["x"])
        assertParseResultEqual(material: "x", parser: parser, expected: expected)
        expected = ParseResult.Node(children: ["x", "y", "z"])
        assertParseResultEqual(material: "x + y +z", parser: parser, expected: expected)
    }
    
    func testCustomExp() {
        let parser = (idParser * (ReservedParser(word: "+")) % ({ return $0 }, { return ASTNode(token: Token(text: $0.token!.text + $2.token!.text)) }))
        var expected = ParseResult.Node(token: Token(text: "x"))
        assertParseResultEqual(material: "x", parser: parser, expected: expected)
        expected = ParseResult.Node(token: Token(text: "xyz"))
        assertParseResultEqual(material: "x + y +z", parser: parser, expected: expected)
    }
}
