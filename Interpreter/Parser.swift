//
//  Parser.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/19.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

/* Common used functions */
func OpsParser(opers: [String]) -> Parser {
    var parsers = opers.map({ ReservedParser(word: $0) })
    let initial = parsers.removeFirst()
    let parser = parsers.reduce(initial) { $0 | $1 }
    return parser
}

func BiOpExprCombiner(oldValue: ParseResult.Value) -> ParseResult.Value {
    // This combiner is used to reduce ExpParser
    return BiOpExpr(oldValue)
}

func BiOpExprFlatter(oldValue: ParseResult.Value) -> ParseResult.Value {
    // This flatter is used to make a concatenated binary operator expression to a BiOpExpr node
    let left = oldValue[0][0]
    let oper = oldValue[0][1]
    let right = oldValue[1]
    return BiOpExpr(values: [left, oper, right])
}

func PrecedenceExprParser(precedence material: [[String]], termParser: Parser) -> Parser {
    var precedence = material
    let firstPrecedence = precedence.removeFirst()
    let initialParser = termParser * (OpsParser(opers: firstPrecedence) ^ BiOpExprCombiner)
    let parser = precedence.reduce(initialParser) {
        (partialResult: Parser, nextPrecedence: [String]) -> Parser in
        return partialResult * (OpsParser(opers: nextPrecedence) ^ BiOpExprCombiner)
    }
    return parser
}

let GroupProcessor: (ParseResult.Value) -> ParseResult.Value = { $0[0][1] }

/* Arithmetic Expressions Parsers */
func ArithExprParserGenerator() -> Parser {
    let precedence = [
        ["*", "/"],
        ["+", "-"]
    ]
    
    return PrecedenceExprParser(precedence: precedence, termParser: ArithTermParser)
}

let ArithExprParser = ~ArithExprParserGenerator

let IntExprParser = TagParser(tag: .Int) ^ { IntExpr($0) }

let VarExprParser = TagParser(tag: .Id) ^ { VarExpr($0) }

let ArithValueParser = IntExprParser | VarExprParser

let ArithGroupParser = ReservedParser(word: "(") + ArithExprParser + ReservedParser(word: ")") ^ GroupProcessor

let ArithTermParser = ArithValueParser | ArithGroupParser

/* Bool Expressions Parsers */
func BoolExprParserGenerator() -> Parser {
    let precedence = [
        ["&&"],
        ["||"]
    ]
    
    return PrecedenceExprParser(precedence: precedence, termParser: BoolTermParser)
}

let BoolExprParser = ~BoolExprParserGenerator

let RelOpsParser = OpsParser(opers: [">", ">=", ">", "<=", "<", "==", "!="])

let RelOpExprParser = ArithExprParser + RelOpsParser + ArithExprParser ^ BiOpExprFlatter

let NotExprParser = ReservedParser(word: "!") + BoolTermParser ^ { NotExpr($0) }

let BoolGroupParser = ReservedParser(word: "(") + BoolExprParser + ReservedParser(word: ")") ^ GroupProcessor

func BoolTermParserGenerator() -> Parser {
    return NotExprParser | BoolGroupParser | RelOpExprParser
}

let BoolTermParser = ~BoolTermParserGenerator

/* Statements Parsers */
let StmtParser = AssignStmtParser | IfStmtParser | WhileStmtParser | PrintStmtParser

let AssignStmtParser = TagParser(tag: .Id) + ReservedParser(word: "=") + ArithExprParser ^ {
    (oldValue: ParseResult.Value) -> ParseResult.Value in
    let id = oldValue[0][0], expr = oldValue[1]
    let newValue = [id, expr]
    return AssignStmt(values: newValue)
}

func CompStmtParserProcessor() -> Parser {
    return RepParser(parser: StmtParser) ^ { CompStmt($0) }
}

let CompStmtParser = ~CompStmtParserProcessor

let BlockParser = ReservedParser(word: "{") + CompStmtParser + ReservedParser(word: "}") ^ GroupProcessor

let IfStmtParser = ReservedParser(word: "if") + BoolExprParser + BlockParser + OptParser(parser: ReservedParser(word: "else") + BlockParser) ^ {
    (oldValue: ParseResult.Value) -> ParseResult.Value in
    let condition = oldValue[0][0][1]
    let trueStmts = oldValue[0][1]
    var newValue = [condition, trueStmts]
    var falseStmts = oldValue[1]
    if falseStmts.value != "nil" {
        // if `else` block exists, unwrap the concat parser result
        newValue.append(falseStmts[1])
    }
    return IfStmt(values: newValue)
}

let WhileStmtParser = ReservedParser(word: "while") + BoolExprParser + BlockParser ^ {
    (oldValue: ParseResult.Value) -> ParseResult.Value in
    let condition = oldValue[0][1]
    let stmts = oldValue[1]
    let newValue = [condition, stmts]
    return WhileStmt(values: newValue)
}

let PrintStmtParser = ReservedParser(word: "print") + ArithExprParser ^ { PrintStmt(values: [$0[1]]) }
