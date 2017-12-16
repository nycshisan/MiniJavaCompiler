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
            parser = (parser * (OpsParser(opers: opers)) % ({ $0 }, { BiOpExpr(children: [$0, $1, $2]) }))
        case .PreOp:
            parser = OptParser(parser: OpsParser(opers: opers)) + parser ^ {
                (oldValue: ParseResult.Node) -> ParseResult.Node in
                if oldValue[0].token == nil {
                    return oldValue[1]
                } else {
                    return PreOpExpr(oldValue)
                }
            }
        }
    }
    return parser
}

let GroupProcessor: (ParseResult.Node) -> ParseResult.Node = { $0[0][1] }

let precedence: [([String], OperatorType)] = [
    (["!"], .PreOp),
    (["*", "/"], .BiOp),
    (["+", "-"], .BiOp),
    ([">", ">=", ">", "<=", "<", "==", "!="], .BiOp),
    (["&&", "||"], .BiOp)
]

let lazyArithExprParser = PrecedenceExprParser(precedence: precedence, termParser: ArithTermParser) - "Expected arithmetic expression"

func ArithExprParserGenerator() -> Parser {
    return lazyArithExprParser
}

let ArithExprParser = ~ArithExprParserGenerator

let IntExprParser = TagParser(tag: .Int) ^ { IntExpr($0) }

let VarExprParser = TagParser(tag: .Id) ^ { VarExpr($0) }

let TypeExprParser = TagParser(tag: .Id) ^ { TypeExpr($0) }

let ArithValueParser = IntExprParser | VarExprParser

let ArithGroupParser = ReservedParser(word: "(") + ArithExprParser + ReservedParser(word: ")") ^ GroupProcessor

let ArithTermParser = ArithValueParser | ArithGroupParser

/* Functions Parser */
let FuncDeclArgTermParser = VarExprParser + ReservedParser(word: ":") + TypeExprParser ^ {
    (oldValue: ParseResult.Node) -> ParseResult.Node in
    return ASTNode(children: [oldValue[0][0], oldValue[1]])
}
let FuncDeclArgsParser = FuncDeclArgTermParser * (ReservedParser(word: ",") ^ { $0 })
let FuncDeclParser = 0

let FuncCallArgTermParser = 0
let FuncCallArgsParser = 0
let FuncCallParser = 0

/* Statements Parsers */
let StmtParser = (AssignStmtParser | IfStmtParser | WhileStmtParser | PrintStmtParser | VarDeclStmtParser) + (ReservedParser(word: ";") - "Missing semicolon") ^ { return $0[0] }

func CompStmtParserGenerator() -> Parser {
    return lazyCompStmtParser
}

let CompStmtParser = ~CompStmtParserGenerator

let lazyCompStmtParser = RepParser(parser: StmtParser) ^ { CompStmt($0) }

let AssignStmtParser = TagParser(tag: .Id) + ReservedParser(word: "=") + ArithExprParser ^ {
    (oldValue: ParseResult.Node) -> ParseResult.Node in
    let id = oldValue[0][0], expr = oldValue[1]
    let newValue = [id, expr]
    return AssignStmt(children: newValue)
}

let VarDeclStmtParser = ReservedParser(word: "var") + VarExprParser + ReservedParser(word: ":") + TypeExprParser + OptParser(parser: ReservedParser(word: "=") + ArithExprParser) ^ {
    (oldValue: ParseResult.Node) -> ParseResult.Node in
    let id = oldValue[0][0][0][1], type = oldValue[0][1]
    var newValue = [id, type]
    let initial = oldValue[1]
    if initial.type != .None {
        let initialExpr = initial[1]
        newValue.append(initialExpr)
    }
    return VarDeclStmt(children: newValue)
}

let BlockParser = ReservedParser(word: "{") + CompStmtParser + ReservedParser(word: "}") ^ GroupProcessor

let IfStmtParser = ReservedParser(word: "if") + ArithGroupParser + BlockParser + OptParser(parser: ReservedParser(word: "else") + BlockParser) ^ {
    (oldValue: ParseResult.Node) -> ParseResult.Node in
    let condition = oldValue[0][0][1]
    let trueStmts = oldValue[0][1]
    var newValue = [condition, trueStmts]
    var falseStmts = oldValue[1]
    if falseStmts.type != .None {
        // if `else` block exists, unwrap the concat parser result
        newValue.append(falseStmts[1])
    }
    return IfStmt(children: newValue)
}

let WhileStmtParser = ReservedParser(word: "while") + ArithGroupParser + BlockParser ^ {
    (oldValue: ParseResult.Node) -> ParseResult.Node in
    let condition = oldValue[0][1]
    let stmts = oldValue[1]
    let newValue = [condition, stmts]
    return WhileStmt(children: newValue)
}

let PrintStmtParser = ReservedParser(word: "print") + ArithExprParser ^ { PrintStmt(children: [$0[1]]) }

/* Main Parser */
let MainParser = PhraseParser(parser: CompStmtParser)
