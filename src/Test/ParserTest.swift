//
//  ParserTest.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/20.
//  Copyright © 2016年 陈十三. All rights reserved.
//

import XCTest

class ParserTest: XCTestCase {
    override func setUp() {
        SemanticActionParser.DEBUG_DISABLE_SEMANTIC_ACTION = true
    }
    
    override func tearDown() {
        SemanticActionParser.DEBUG_DISABLE_SEMANTIC_ACTION = false
    }
    
    func assertParseResultEqual(material: String, parser: BaseParser, expected: ParseResult) {
        let tokenizer = Tokenizer()
        var tokens = tokenizer.forceTokenize(material: material)
        let actual = PhraseParser(parser: parser).parse(tokens: &tokens, pos: 0)
        XCTAssertNotNil(actual)
        XCTAssertEqual(actual!, expected)
    }
    
    /* Expression Tests */
    func testIntLiteral() {
        let parser = IntLiteralParser
        let material = "3"
        let expected = ParseResult(token: Token(text: "3", tag: .Int))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testReservedLiteral() {
        let reservedLiteral = ["true", "false", "this"]
        XCTAssert(false)
    }
    
    func testPreOp() {
        let parser = PrecedenceExprParser
        let material = "!1 + 1"
        let expected = ParseResult(children: [])
        let inner = ParseResult(children: [])
        inner.append(ParseResult(token: Token(text: "!", tag: .Reserved)))
        inner.append(ParseResult(token: Token(text: "1", tag: .Int)))
        expected.append(inner)
        expected.append(ParseResult(token: Token(text: "+", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "1", tag: .Int)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testBiOp() {
        let parser = PrecedenceExprParser
        let material = "1 + 1"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: Token(text: "1", tag: .Int)))
        expected.append(ParseResult(token: Token(text: "+", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "1", tag: .Int)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testGroup() {
        XCTAssert(false)
    }
    
    func testComplexArithExpr() {
        XCTAssert(false)
    }
    
    func testNewIntArray() {
        let parser = NewIntArrayParser
        let material = "new int [1]"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: Token(text: "new", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "int", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "[", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "1", tag: .Int)))
        expected.append(ParseResult(token: Token(text: "]", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testNewObject() {
        let parser = NewObjectParser
        let material = "new sth()"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: Token(text: "new", tag: .Reserved)))
        expected.append(ParseResult(token: "sth"))
        expected.append(ParseResult(token: Token(text: "(", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: ")", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testSubscript() {
        let parser = SubscriptExprParser
        let material = "a[2]"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: "a"))
        expected.append(ParseResult(token: Token(text: "[", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "2", tag: .Int)))
        expected.append(ParseResult(token: Token(text: "]", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testLength() {
        let parser = LengthExprParser
        let material = "l.length"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: "l"))
        expected.append(ParseResult(token: Token(text: ".", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "length", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testMethodInvocationArguments() {
        let parser = MethodInvocationArgumentsParser
        var material = "x"
        var expected = ParseResult(children: ["x"])
        assertParseResultEqual(material: material, parser: parser, expected: expected)
        material = "x, y, z"
        expected = ParseResult(children: ["x", "y", "z"])
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testMethodInvocation() {
        
    }
    
    func testCompoundExpr() {
        XCTAssert(false)
    }
    
    /* Identifier Tests */
    func testIdentifier() {
        let parser = IdentifierParser
        let material = "i"
        let expected = ParseResult(token: "i")
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
}
