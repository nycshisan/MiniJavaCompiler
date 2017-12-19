//
//  Parser.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/19.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

/* Main Parsers */
let GoalParser = PhraseParser(parser: MainClassParser + RepParser(parser: ClassDeclarationParser))

let MainClassParser = ReservedParser("class") + IdentifierParser + ReservedParser("{") + ReservedParser("public") + ReservedParser("static") + ReservedParser("void") + ReservedParser("main") + ReservedParser("(") + ReservedParser("String") + ReservedParser("[") + ReservedParser("]") + IdentifierParser + ReservedParser(")") + StmtParser + ReservedParser("}") ^ SemanticActionFactory.constructWrapAction(description: "Main Class")

let ClassDeclarationParser = ReservedParser("class") + IdentifierParser + OptParser(parser: ReservedParser("extends") + IdentifierParser) + ReservedParser("{") + RepParser(parser: VarDeclarationParser) + RepParser(parser: MethodDeclarationParser) + ReservedParser("}") ^ SemanticActionFactory.constructWrapAction(description: "Class Declaration")

let VarDeclarationParser = TypeParser + IdentifierParser + ReservedParser(";") ^ SemanticActionFactory.constructWrapAction(description: "Variable Declaration")

let MethodDeclarationArgumentsParser = TypeParser
let MethodDeclarationParser = ReservedParser("public") + TypeParser + IdentifierParser + ReservedParser("(") + MethodDeclarationArgumentsParser + ReservedParser(")") + ReservedParser("{") + RepParser(parser: VarDeclarationParser) + RepParser(parser: StmtParser) + ReservedParser("}") ^ SemanticActionFactory.constructWrapAction(description: "Method Declaration")

/* Type Parsers */
let IntArrayTypeParser = ReservedParser("int") + ReservedParser("(") + ReservedParser(")") ^ SemanticActionFactory.constructDescAction(description: "New Int Array")

let TypeParser = IntArrayTypeParser | ReservedParser("boolean") | ReservedParser("int") | IdentifierParser ^ SemanticActionFactory.constructWrapAction(description: "Type")

/* Statement Parsers */
let CompoundStmtParser = ReservedParser("{") + RepParser(parser: StmtParser) + ReservedParser("}") ^ GroupAction

let IfStmtParser = ReservedParser("if") + ReservedParser("(") + ExprParser + ReservedParser(")") + StmtParser + ReservedParser("else") + StmtParser ^ SemanticActionFactory.constructWrapAction(description: "If Statement")

let WhileStmtParser = ReservedParser("while") + ReservedParser("(") + ExprParser + ReservedParser(")") + StmtParser ^ SemanticActionFactory.constructWrapAction(description: "While Statement")

let PrintStmtParser = ReservedParser("System.out.println") + ReservedParser("(") + ExprParser + ReservedParser(")") + ReservedParser(";") ^ SemanticActionFactory.constructWrapAction(description: "Print Statement")

let AssignmentStmtParser = IdentifierParser + ReservedParser("=") + ExprParser ^ SemanticActionFactory.constructWrapAction(description: "Assignment Statement")

let SubscriptAssignmentStmtParser = IdentifierParser + ReservedParser("[") + ExprParser + ReservedParser("]") + ReservedParser("=") + ExprParser ^ SemanticActionFactory.constructWrapAction(description: "Subscript Assignment Statement")

let ReturnStmtParser = ReservedParser("return") + ExprParser + ReservedParser(";") ^ SemanticActionFactory.constructWrapAction(description: "Return Statement")

// Lazy Statement Parser
func StmtParserGenerator() -> BaseParser {
    return CompoundStmtParser | IfStmtParser | WhileStmtParser | PrintStmtParser | AssignmentStmtParser | SubscriptAssignmentStmtParser | ReturnStmtParser ^ SemanticActionFactory.constructWrapAction(description: "Statement")
}
let StmtParser = ~StmtParserGenerator

/* Expression Parsers */
// Priority Support
enum OperatorType {
    case PreOp
    case BiOp
    // Hold expansibility for postfix operators
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
        case .PreOp:
            parser = OptParser(parser: OpsParser(opers: opers)) + parser ^ PreOpAction
            (parser as! SemanticActionParser).force = true
        case .BiOp:
            parser = (parser * (OpsParser(opers: opers)) % {
                (partial: ParseResult, separator: ParseResult, new: ParseResult) -> ParseResult in
                partial.append(separator)
                partial.append(new)
                return partial
            }) ^ BiOpAction
            (parser as! SemanticActionParser).force = true
        case .PostOp:
            fatalError()
        }
    }
    return parser
}
let Precedence: [([String], OperatorType)] = [
    (["!"], .PreOp),
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

let ExprValueParser = IntLiteralParser | ReservedParser("true") | ReservedParser("false") | IdentifierParser | ReservedParser("this") | NewIntArrayParser | NewObjectParser

let ExprGroupParser = ReservedParser("(") + ExprParser + ReservedParser(")") ^ GroupAction

let ExprTermParser = ExprValueParser | ExprGroupParser

// Lazy Expression Parser
func ExprParserGenerator() -> BaseParser {
    return PrecedenceExprParser | SubscriptExprParser | LengthExprParser | MethodInvocationExprParser ^ SemanticActionFactory.constructWrapAction(description: "Expression")
}
let ExprParser = ~ExprParserGenerator

/* Identifier Parser */
let IdentifierParser = TagParser(.Id) ^ SemanticActionFactory.constructWrapAction(description: "Identifier")
