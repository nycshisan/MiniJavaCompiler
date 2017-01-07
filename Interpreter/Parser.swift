//
//  Parser.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/19.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

/* Arithmetic Expressions Parsers */
enum OperatorType {
    case BiOp
    case PreOp
}

func OpsParser(opers: [String]) -> Parser {
    var parsers = opers.map({ ReservedParser(word: $0) })
    let initial = parsers.removeFirst()
    let parser = parsers.reduce(initial) { $0 | $1 }
    return parser
}

func PrecedenceExprParser(precedence: [(opers: [String], type: OperatorType)], termParser: Parser) -> Parser {
    var parser = termParser
    for (opers, type) in precedence {
        switch type {
        case .BiOp:
            parser = parser * (OpsParser(opers: opers) ^ { BiOpExpr($0) })
        case .PreOp:
            parser = OptParser(parser: OpsParser(opers: opers)) + parser ^ { PreOpExpr($0) }
        }
    }
    return parser
}

let GroupProcessor: (ParseResult.Value) -> ParseResult.Value = { $0[0][1] }

let precedence: [([String], OperatorType)] = [
    (["!"], .PreOp),
    (["*", "/"], .BiOp),
    (["+", "-"], .BiOp),
    ([">", ">=", ">", "<=", "<", "==", "!="], .BiOp),
    (["&&", "||"], .BiOp)
]

let lazyArithExprParser = PrecedenceExprParser(precedence: precedence, termParser: ArithTermParser)

func ArithExprParserGenerator() -> Parser {
    return lazyArithExprParser
}

let ArithExprParser = ~ArithExprParserGenerator

let IntExprParser = TagParser(tag: .Int) ^ { IntExpr($0) }

let VarExprParser = TagParser(tag: .Id) ^ { VarExpr($0) }

let ArithValueParser = IntExprParser | VarExprParser

let ArithGroupParser = ReservedParser(word: "(") + ArithExprParser + ReservedParser(word: ")") ^ GroupProcessor

let ArithTermParser = ArithValueParser | ArithGroupParser

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

let IfStmtParser = ReservedParser(word: "if") + ArithExprParser + BlockParser + OptParser(parser: ReservedParser(word: "else") + BlockParser) ^ {
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

let WhileStmtParser = ReservedParser(word: "while") + ArithExprParser + BlockParser ^ {
    (oldValue: ParseResult.Value) -> ParseResult.Value in
    let condition = oldValue[0][1]
    let stmts = oldValue[1]
    let newValue = [condition, stmts]
    return WhileStmt(values: newValue)
}

let PrintStmtParser = ReservedParser(word: "print") + ArithExprParser ^ { PrintStmt(values: [$0[1]]) }

/* Main Parser */
let MainParser = PhraseParser(parser: CompStmtParser)
