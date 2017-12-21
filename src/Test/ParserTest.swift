//
//  ParserTest.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/20.
//  Copyright © 2016年 Nycshisan. All rights reserved.
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
        var tokens = tokenizer.tokenize(material: material)!
        let actual = PhraseParser(parser: parser).parse(tokens: &tokens, pos: 0)
        XCTAssertEqual(actual!, expected)
    }
    
    /* Main Tests */
    func testMainClass() {
        let parser = MainClassParser
        let material = "class Main { public static void main(String [] args) {}}"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: Token(text: "class", tag: .Reserved)))
        expected.append(ParseResult(token: "Main"))
        expected.append(ParseResult(token: Token(text: "{", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "public", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "static", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "void", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "main", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "(", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "String", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "[", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "]", tag: .Reserved)))
        expected.append(ParseResult(token: "args"))
        expected.append(ParseResult(token: Token(text: ")", tag: .Reserved)))
        let inner = ParseResult(children: [])
        expected.append(inner)
        expected.append(ParseResult(token: Token(text: "}", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testClassDeclaration() {
        let parser = ClassDeclarationParser
        let material = "class C extends CC {public int v() {}}"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: Token(text: "class", tag: .Reserved)))
        expected.append(ParseResult(token: "C"))
        var inner = ParseResult(children: [])
        inner.append(ParseResult(token: Token(text: "extends", tag: .Reserved)))
        inner.append(ParseResult(token: "CC"))
        expected.append(inner)
        expected.append(ParseResult(token: Token(text: "{", tag: .Reserved)))
        inner = ParseResult(children: [])
        expected.append(inner)
        let innest = ParseResult(children: [])
        let innest2 = ParseResult(children: [])
        innest2.append(ParseResult(token: Token(text: "public", tag: .Reserved)))
        innest2.append(ParseResult(token: Token(text: "int", tag: .Reserved)))
        innest2.append(ParseResult(token: "v"))
        var innest3 = ParseResult(children: [])
        innest2.append(innest3)
        innest2.append(ParseResult(token: Token(text: "{", tag: .Reserved)))
        innest3 = ParseResult(children: [])
        innest2.append(innest3)
        innest3 = ParseResult(children: [])
        innest2.append(innest3)
        innest2.append(ParseResult(token: Token(text: "}", tag: .Reserved)))
        innest.append(innest2)
        expected.append(innest)
        expected.append(ParseResult(token: Token(text: "}", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testVarDeclaration() {
        let parser = VarDeclarationParser
        let material = "int x;"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: Token(text: "int", tag: .Reserved)))
        expected.append(ParseResult(token: "x"))
        expected.append(ParseResult(token: Token(text: ";", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testMethodDeclaration() {
        var parser: BaseParser = MethodDeclarationArgumentsParser
        var material = "int x, int y"
        var expected = ParseResult(children: [])
        var inner = ParseResult(children: [])
        inner.append(ParseResult(token: Token(text: "int", tag: .Reserved)))
        inner.append(ParseResult(token: "x"))
        expected.append(inner)
        inner = ParseResult(children: [])
        inner.append(ParseResult(token: Token(text: "int", tag: .Reserved)))
        inner.append(ParseResult(token: "y"))
        expected.append(inner)
        assertParseResultEqual(material: material, parser: parser, expected: expected)
        parser = MethodDeclarationParser
        material = "public int add(int x, int y) { int c; c = a + b; return c;}"
        let expected_ = expected
        expected = ParseResult(children: [])
        expected.append(ParseResult(token: Token(text: "public", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "int", tag: .Reserved)))
        expected.append(ParseResult(token: "add"))
        expected.append(expected_)
        expected.append(ParseResult(token: Token(text: "{", tag: .Reserved)))
        inner = ParseResult(children: [])
        inner.append(ParseResult(token: Token(text: "int", tag: .Reserved)))
        inner.append(ParseResult(token: "c"))
        inner.append(ParseResult(token: Token(text: ";", tag: .Reserved)))
        expected.append(ParseResult(children: [inner]))
        let innest = ParseResult(children: [])
        inner = ParseResult(children: [])
        inner.append(ParseResult(token: "c"))
        inner.append(ParseResult(token: Token(text: "=", tag: .Reserved)))
        let innest2 = ParseResult(children: [])
        innest2.append(ParseResult(token: "a"))
        innest2.append(ParseResult(token: Token(text: "+", tag: .Reserved)))
        innest2.append(ParseResult(token: "b"))
        inner.append(innest2)
        inner.append(ParseResult(token: Token(text: ";", tag: .Reserved)))
        innest.append(inner)
        inner = ParseResult(children: [])
        inner.append(ParseResult(token: Token(text: "return", tag: .Reserved)))
        inner.append(ParseResult(token: "c"))
        inner.append(ParseResult(token: Token(text: ";", tag: .Reserved)))
        innest.append(inner)
        expected.append(innest)
        expected.append(ParseResult(token: Token(text: "}", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    /* Type Tests */
    func testType() {
        let parser = TypeParser
        var material = "C"
        var expected = ParseResult(token: "C")
        assertParseResultEqual(material: material, parser: parser, expected: expected)
        material = "int"
        expected = ParseResult(token: Token(text: "int", tag: .Reserved))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
        material = "boolean"
        expected = ParseResult(token: Token(text: "boolean", tag: .Reserved))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
        material = "int[]"
        expected = ParseResult(children: [])
        expected.append(ParseResult(token: Token(text: "int", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "[", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "]", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    /* Statement Tests */
    func testIf() {
        let parser = IfStmtParser
        let material = "if(!false) a = 1; else {a = 2;}"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: Token(text: "if", tag: .Reserved)))
        var inner = ParseResult(children: [])
        inner.append(ParseResult(token: Token(text: "!", tag: .Reserved)))
        inner.append(ParseResult(token: Token(text: "false", tag: .Reserved)))
        expected.append(inner)
        inner = ParseResult(children: [])
        inner.append(ParseResult(token: "a"))
        inner.append(ParseResult(token: Token(text: "=", tag: .Reserved)))
        inner.append(ParseResult(token: Token(text: "1", tag: .Int)))
        inner.append(ParseResult(token: Token(text: ";", tag: .Reserved)))
        expected.append(inner)
        expected.append(ParseResult(token: Token(text: "else", tag: .Reserved)))
        inner = ParseResult(children: [])
        inner.append(ParseResult(token: "a"))
        inner.append(ParseResult(token: Token(text: "=", tag: .Reserved)))
        inner.append(ParseResult(token: Token(text: "2", tag: .Int)))
        inner.append(ParseResult(token: Token(text: ";", tag: .Reserved)))
        expected.append(ParseResult(children: [inner]))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testWhile() {
        let parser = WhileStmtParser
        let material = "while (true) a = 1;"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: Token(text: "while", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "true", tag: .Reserved)))
        let inner = ParseResult(children: [])
        inner.append(ParseResult(token: "a"))
        inner.append(ParseResult(token: Token(text: "=", tag: .Reserved)))
        inner.append(ParseResult(token: Token(text: "1", tag: .Int)))
        inner.append(ParseResult(token: Token(text: ";", tag: .Reserved)))
        expected.append(inner)
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testPrint() {
        let parser = PrintStmtParser
        let material = "System.out.println(x);"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: Token(text: "System.out.println", tag: .Reserved)))
        expected.append(ParseResult(token: "x"))
        expected.append(ParseResult(token: Token(text: ";", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testAssignment() {
        let parser = AssignmentStmtParser
        let material = "i = 2;"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: "i"))
        expected.append(ParseResult(token: Token(text: "=", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "2", tag: .Int)))
        expected.append(ParseResult(token: Token(text: ";", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testSubscriptAssignment() {
        let parser = SubscriptAssignmentStmtParser
        let material = "a[3] = 2;"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: "a"))
        expected.append(ParseResult(token: Token(text: "[", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "3", tag: .Int)))
        expected.append(ParseResult(token: Token(text: "]", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "=", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "2", tag: .Int)))
        expected.append(ParseResult(token: Token(text: ";", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testReturn() {
        let parser = ReturnStmtParser
        let material = "return true;"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: Token(text: "return", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "true", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: ";", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
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
        let parser = ExprTermParser
        for literal in reservedLiteral {
            let expected = ParseResult(token: Token(text: literal, tag: .Reserved))
            assertParseResultEqual(material: literal, parser: parser, expected: expected)
        }
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
        let parser = PrecedenceExprParser
        let material = "!(1 + 1)"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: Token(text: "!", tag: .Reserved)))
        let inner = ParseResult(children: [])
        inner.append(ParseResult(token: Token(text: "1", tag: .Int)))
        inner.append(ParseResult(token: Token(text: "+", tag: .Reserved)))
        inner.append(ParseResult(token: Token(text: "1", tag: .Int)))
        expected.append(inner)
        assertParseResultEqual(material: material, parser: parser, expected: expected)
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
        let parser = MethodInvocationExprParser
        let material = "this.m(x, 1)"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: Token(text: "this", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: ".", tag: .Reserved)))
        expected.append(ParseResult(token: "m"))
        expected.append(ParseResult(token: Token(text: "(", tag: .Reserved)))
        let inner = ParseResult(children: [])
        inner.append(ParseResult(token: "x"))
        inner.append(ParseResult(token: Token(text: "1", tag: .Int)))
        expected.append(inner)
        expected.append(ParseResult(token: Token(text: ")", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    func testExpr() {
        let parser = ExprParser
        let material = "l.length"
        let expected = ParseResult(children: [])
        expected.append(ParseResult(token: "l"))
        expected.append(ParseResult(token: Token(text: ".", tag: .Reserved)))
        expected.append(ParseResult(token: Token(text: "length", tag: .Reserved)))
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
    
    /* Identifier Tests */
    func testIdentifier() {
        let parser = IdentifierParser
        let material = "i"
        let expected = ParseResult(token: "i")
        assertParseResultEqual(material: material, parser: parser, expected: expected)
    }
}
