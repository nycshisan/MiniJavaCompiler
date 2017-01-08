//
//  ParserTest.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/20.
//  Copyright © 2016年 陈十三. All rights reserved.
//

import XCTest

func ==<T: Equatable> (lhs: Any, rhs: T) -> Bool {
    return (lhs as! T) == rhs
}

class ParserTest: XCTestCase {
    
    var env: [String: Any] = [:]
    
    override func setUp() {
        env["+"] = {
            (left: Any, right: Any) -> Any in
            let l = left as! Int
            let r = right as! Int
            return l + r
        }
        env["-"] = {
            (left: Any, right: Any) -> Any in
            let l = left as! Int
            let r = right as! Int
            return l - r
        }
        env["*"] = {
            (left: Any, right: Any) -> Any in
            let l = left as! Int
            let r = right as! Int
            return l * r
        }
        env["/"] = {
            (left: Any, right: Any) -> Any in
            let l = left as! Int
            let r = right as! Int
            return l / r
        }
        env[">"] = {
            (left: Any, right: Any) -> Any in
            let l = left as! Int
            let r = right as! Int
            return l > r
        }
        env["<"] = {
            (left: Any, right: Any) -> Any in
            let l = left as! Int
            let r = right as! Int
            return l < r
        }
        env["&&"] = {
            (left: Any, right: Any) -> Any in
            let l = left as! Bool
            let r = right as! Bool
            return l && r
        }
        env["||"] = {
            (left: Any, right: Any) -> Any in
            let l = left as! Bool
            let r = right as! Bool
            return l || r
        }
        env["!"] = {
            (old: Any) -> Any in
            let oldBool = old as! Bool
            return !oldBool
        }
        env["a"] = 0
        env["c"] = 0
    }
    
    override func tearDown() {
        env = [:]
    }
    
    func assertParseResultEqual(material: String, parser: Parser, expected: Any) {
        let tokenizer = Tokenizer()
        let tokens = try! tokenizer.tokenize(material: material)
        let actual = PhraseParser(parser: parser).parse(tokens: tokens, pos: 0)
        XCTAssertNotNil(actual)
        let actualValue: Any? = actual!.node.eval(environment: &env)
        if let i = expected as? Int {
            XCTAssertTrue(actualValue! == i)
        }
        if let b = expected as? Bool {
            XCTAssertTrue(actualValue! == b)
        }
        if let si = expected as? [(String, Int)] {
            for pair in si {
                XCTAssertTrue(env[pair.0]! == pair.1)
            }
        }
    }
    
    func testPrecedence() {
        assertParseResultEqual(material: "2 + 3 * 4", parser: ArithExprParser, expected: 14)
    }
    
    func testIntExpr() {
        assertParseResultEqual(material: "12", parser: ArithExprParser, expected: 12)
    }
    
    func testVarExpr() {
        env["a"] = 123
        assertParseResultEqual(material: "a", parser: ArithExprParser, expected: 123)
    }
    
    func testGroupExpr() {
        assertParseResultEqual(material: "(222)", parser: ArithExprParser, expected: 222)
        assertParseResultEqual(material: "(2 + 3) * 4", parser: ArithExprParser, expected: 20)
    }
    
    func testBiOpExpr() {
        assertParseResultEqual(material: "2 * 3 + 4", parser: ArithExprParser, expected: 10)
    }
    
    func testRelOpExpr() {
        assertParseResultEqual(material: "2 > 3", parser: ArithExprParser, expected: false)
    }
    
    func testNotExpr() {
        assertParseResultEqual(material: "! (2 > 3)", parser: ArithExprParser, expected: true)
    }
    
    func testAndExpr() {
        assertParseResultEqual(material: "4 > 3 && 2 > 1", parser: ArithExprParser, expected: true)
    }
    
    func testBoolExprLogic() {
        assertParseResultEqual(material: "5 < 2 && 6 < 4 || 5 < 6", parser: ArithExprParser, expected: true)
    }
    
    func testBoolGroupLogic() {
        assertParseResultEqual(material: "5 < 2 && (6 < 4 || 5 < 6)", parser: ArithExprParser, expected: false)
    }
    
    func testNotPrecedence() {
        assertParseResultEqual(material: "! (3 < 2) && 3 < 4", parser: ArithExprParser, expected: true)
    }
    
    func testAssignStmt() {
        assertParseResultEqual(material: "a = 2", parser: CompStmtParser, expected: [("a", 2)])
    }
    
    func testCompStmt() {
        assertParseResultEqual(material: "a = 2\nc = 3", parser: CompStmtParser, expected: [("a", 2), ("c", 3)])
    }
    
    func testIfStmt() {
        assertParseResultEqual(material: "if 5 > 3 { a = 3}", parser: CompStmtParser, expected: [("a", 3)])
    }
    
    func testIfElseStmt() {
        assertParseResultEqual(material: "if 2 > 3 { a = 3} else { a = 5}", parser: CompStmtParser, expected: [("a", 5)])
    }
    
    func testWhileStmt() {
        assertParseResultEqual(material: "a = 0\nwhile a < 2 {a = a + 2}", parser: CompStmtParser, expected: [("a", 2)])
    }
    
    func textDeclStmt() {
        // todo
    }
}
