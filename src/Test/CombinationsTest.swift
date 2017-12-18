//
//  CombinationsTest.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/18.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

import XCTest

extension BaseASTNode: Equatable {
    static func == (lhs: BaseASTNode, rhs: BaseASTNode) -> Bool {
        if !(lhs.token == nil && rhs.token == nil) && (lhs.token! != rhs.token!) { return false }
        if !(lhs.children == nil && rhs.children == nil) && (lhs.children! != rhs.children!) { return false }
        return true
    }
}

extension ParseResult {
    convenience init(token: Token?) {
        self.init(token: token, pos: 0)
    }
    convenience init(children: [ParseResult]?) {
        self.init(children: children, pos: 0)
    }
    convenience init(token: String) {
        self.init(token: Token(text: token, tag: .Id))
    }
    convenience init(children: [String]) {
        self.init(children: children.map { ParseResult(token: Token(text: $0, tag: .Id)) })
    }
}

class CombinationsTest: XCTestCase {
    
    var idParser: BaseParser = TagParser(.Id)
    var intParser: BaseParser = TagParser(.Int)
    
    func assertParseResultEqual(material: String, parser: BaseParser, expected: ParseResult?) {
        let tokenizer = Tokenizer()
        var tokens = tokenizer.forceTokenize(material: material)
        let actual = parser.parse(tokens: &tokens, pos: 0)
        XCTAssertEqual(actual, expected)
    }
    
    func testTag() {
        let expected = ParseResult(token: "some_id")
        assertParseResultEqual(material: "some_id ", parser: TagParser(.Id), expected: expected)
    }

    func testReservedWords() {
        for word in ReservedWords {
            let expected = ParseResult(token: Token(text: word, tag: .Reserved))
            assertParseResultEqual(material: word, parser: ReservedParser(word), expected: expected)
        }
    }

    func testConcat() {
        let expected = ParseResult(children: ["x", "y"])
        let parser = idParser + idParser
        assertParseResultEqual(material: "x y", parser: parser, expected: expected)
    }

    func testConcatFlattening() {
        let expected = ParseResult(children: ["x", "y", "z"])
        let parser = (idParser + idParser) as BaseParser + idParser // I do not know why here the concatenation of the first two idParser must be cast to Parser, one of me and Swift compiler must be stupid
        assertParseResultEqual(material: "x y z", parser: parser, expected: expected)
    }

    func testAlternate() {
        let parser = idParser | intParser | idParser
        var expected = ParseResult(token: Token(text: "123", tag: .Int))
        assertParseResultEqual(material: "123", parser: parser, expected: expected)
        expected = ParseResult(token: Token(text: "asd", tag: .Id))
        assertParseResultEqual(material: "asd", parser: parser, expected: expected)
    }

    func testOpt() {
        let parser = OptParser(parser: idParser)
        let expected1 = ParseResult(token: "asd")
        let expected2 = ParseResult(token: nil)
        assertParseResultEqual(material: "asd", parser: parser, expected: expected1)
        assertParseResultEqual(material: "123", parser: parser, expected: expected2)
    }

    func testRep() {
        let parser = RepParser(parser: idParser)
        let expected = ParseResult(children: ["x", "y", "z"])
        assertParseResultEqual(material: "x y z", parser: parser, expected: expected)
    }

    func testProcess() {
        let parser = idParser ^ { ParseResult(token: $0.token!.text + $0.token!.text) }
        let expected = ParseResult(token: "xx")
        assertParseResultEqual(material: "x", parser: parser, expected: expected)
    }

    func testLazy() {
        let parser = ~{ self.idParser }
        let expected = ParseResult(token: "xx")
        assertParseResultEqual(material: "xx", parser: parser, expected: expected)
    }

    func testExp() {
        let parser = idParser * ReservedParser("+")
        var expected = ParseResult(children: ["x"])
        assertParseResultEqual(material: "x", parser: parser, expected: expected)
        expected = ParseResult(children: ["x", "y", "z"])
        assertParseResultEqual(material: "x + y +z", parser: parser, expected: expected)
    }

    func testCustomExp() {
        let parser = (idParser * (ReservedParser("+")) % ({ $0 }, { ParseResult(token: $0.token!.text + $2.token!.text) }))
        var expected = ParseResult(token: "x")
        assertParseResultEqual(material: "x", parser: parser, expected: expected)
        expected = ParseResult(token: "xyz")
        assertParseResultEqual(material: "x + y +z", parser: parser, expected: expected)
    }
}
