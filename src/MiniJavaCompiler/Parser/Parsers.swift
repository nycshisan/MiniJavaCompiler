//
//  Parser.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/19.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

/* Type Parsers */
let IntArrayTypeParser = ReservedParser("int") + ReservedParser("(") + ReservedParser(")") ^ SemanticActionFactory.constructDescAction(description: "New Int Array")

let TypeParser = IntArrayTypeParser | ReservedParser("boolean") | ReservedParser("int") | IdentifierParser ^ SemanticActionFactory.constructWrapAction(description: "Type")

/* Expression Parsers */
// Priority Support
enum OperatorType {
    // Hold expansibility for postfix operators
    case BiOp
    case PostOp
}

func OpsParser(opers: [String]) -> BaseParser {
    var parsers = opers.map({ ReservedParser($0) })
    let initial = parsers.removeFirst()
    let parser = parsers.reduce(initial) { $0 | $1 }
    return parser
}

func constructPrecedenceExprParser(precedence: [(opers: [String], type: OperatorType)], termParser: BaseParser) -> BaseParser {
    var parser = termParser
    for (opers, type) in precedence {
        switch type {
        case .BiOp:
            parser = (parser * (OpsParser(opers: opers)) % ({ $0 }, { BaseASTNode(children: [$0, $1, $2], pos: $2.pos) })) ^ SemanticActionFactory.constructWrapAction(description: "Binary Operator")
        case .PostOp:
            fatalError()
        }
    }
    return parser
}

let Precedence: [([String], OperatorType)] = [
    (["*", "/"], .BiOp),
    (["+", "-"], .BiOp),
    ([">", ">=", ">", "<=", "<", "==", "!="], .BiOp),
    (["&&", "||"], .BiOp)
]

let PrecedenceExprParser = constructPrecedenceExprParser(precedence: Precedence, termParser: ExprTermParser)

// Parser for left-recursion expressions
let SubscriptExprParser = ExprTermParser + ReservedParser("[") + ExprParser + ReservedParser("]") ^ SemanticActionFactory.constructWrapAction(description: "Subscript Expression")
let LengthExprParser = ExprTermParser + ReservedParser(".") + ReservedParser("length") ^ SemanticActionFactory.constructWrapAction(description: "Length Expression")
let MethodInvocationArgumentsParser = ExpParser(parser: ExprParser, separator: ReservedParser(","))
let MethodInvocationExprParser = ExprTermParser + ReservedParser(".") + IdentifierParser + ReservedParser("(") + MethodInvocationArgumentsParser + ReservedParser(")") ^ SemanticActionFactory.constructWrapAction(description: "Method Invocation Expression")

// Parser for non-left-recursion expressions
let IntLiteralParser = TagParser(.Int) ^ SemanticActionFactory.constructWrapAction(description: "Int Literal")
let NewIntArrayParser = ReservedParser("new") + ReservedParser("int") + ReservedParser("[") + ExprParser + ReservedParser("]") ^ SemanticActionFactory.constructWrapAction(description: "New Int Array")
let NewObjectParser = ReservedParser("new") + IdentifierParser + ReservedParser("(") + ReservedParser(")") ^ SemanticActionFactory.constructWrapAction(description: "New Object")

let PreOps = ["!"]
let PreOpParser = OptParser(parser: OpsParser(opers: PreOps)) + ExprParser ^ SemanticActionFactory.constructWrapAction(description: "Prefix Operator")

let ExprValueParser = IntLiteralParser | ReservedParser("true") | ReservedParser("false") | IdentifierParser | ReservedParser("this") | NewIntArrayParser | NewObjectParser
let ExprGroupParser = ReservedParser("(") + ExprParser + ReservedParser(")") ^ GroupAction
let ExprTermParser = ExprValueParser | ExprGroupParser | PreOpParser

// Lazy Expression Parser
func ExprParserGenerator() -> BaseParser {
    return PrecedenceExprParser
}
let ExprParser = ~ExprParserGenerator

/* Identifier Parser */
let IdentifierParser = TagParser(.Id) ^ SemanticActionFactory.constructWrapAction(description: "Identifier")

///* Functions Parser */
//let FuncDeclArgTermParser = VarExprParser + ReservedParser(word: ":") + TypeExprParser ^ {
//    (oldValue: ParseResult) -> ParseResult in
//    return ASTNode(children: [oldValue[0][0], oldValue[1]])
//}
//let FuncDeclArgsParser = FuncDeclArgTermParser * (ReservedParser(word: ",") ^ { $0 })
//let FuncDeclParser = 0
//
//let FuncCallArgTermParser = 0
//let FuncCallArgsParser = 0
//let FuncCallParser = 0
//
///* Statements Parsers */
//let StmtParser = (AssignStmtParser | IfStmtParser | WhileStmtParser | PrintStmtParser | VarDeclStmtParser) + (ReservedParser(word: ";") - "Missing semicolon") ^ { return $0[0] }
//
//func CompStmtParserGenerator() -> Parser {
//    return lazyCompStmtParser
//}
//
//let CompStmtParser = ~CompStmtParserGenerator
//
//let lazyCompStmtParser = RepParser(parser: StmtParser) ^ { CompStmt($0) }
//
//let AssignStmtParser = TagParser(tag: .Id) + ReservedParser(word: "=") + ArithExprParser ^ {
//    (oldValue: ParseResult) -> ParseResult in
//    let id = oldValue[0][0], expr = oldValue[1]
//    let newValue = [id, expr]
//    return AssignStmt(children: newValue)
//}
//
//let VarDeclStmtParser = ReservedParser(word: "var") + VarExprParser + ReservedParser(word: ":") + TypeExprParser + OptParser(parser: ReservedParser(word: "=") + ArithExprParser) ^ {
//    (oldValue: ParseResult) -> ParseResult in
//    let id = oldValue[0][0][0][1], type = oldValue[0][1]
//    var newValue = [id, type]
//    let initial = oldValue[1]
//    if initial.type != .None {
//        let initialExpr = initial[1]
//        newValue.append(initialExpr)
//    }
//    return VarDeclStmt(children: newValue)
//}
//
//let BlockParser = ReservedParser(word: "{") + CompStmtParser + ReservedParser(word: "}") ^ GroupProcessor
//
//let IfStmtParser = ReservedParser(word: "if") + ArithGroupParser + BlockParser + OptParser(parser: ReservedParser(word: "else") + BlockParser) ^ {
//    (oldValue: ParseResult) -> ParseResult in
//    let condition = oldValue[0][0][1]
//    let trueStmts = oldValue[0][1]
//    var newValue = [condition, trueStmts]
//    var falseStmts = oldValue[1]
//    if falseStmts.type != .None {
//        // if `else` block exists, unwrap the concat parser result
//        newValue.append(falseStmts[1])
//    }
//    return IfStmt(children: newValue)
//}
//
//let WhileStmtParser = ReservedParser(word: "while") + ArithGroupParser + BlockParser ^ {
//    (oldValue: ParseResult) -> ParseResult in
//    let condition = oldValue[0][1]
//    let stmts = oldValue[1]
//    let newValue = [condition, stmts]
//    return WhileStmt(children: newValue)
//}
//
//let PrintStmtParser = ReservedParser(word: "print") + ArithExprParser ^ { PrintStmt(children: [$0[1]]) }
//
///* Main Parser */
//let MainParser = PhraseParser(parser: CompStmtParser)

