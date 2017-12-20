//
//  Parser.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/19.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

/* Main Parsers */
let GoalParser = PhraseParser(parser: MainClassParser + RepParser(parser: ClassDeclarationParser, desc: "Class Declarations")) ^ SemanticActionFactory.DescAction(description: "Goal")

let MainClassParser = ReservedParser("class") + IdentifierParser + ReservedParser("{") + ReservedParser("public") + ReservedParser("static") + ReservedParser("void") + ReservedParser("main") + ReservedParser("(") + ReservedParser("String") + ReservedParser("[") + ReservedParser("]") + IdentifierParser + ReservedParser(")") + StmtParser + ReservedParser("}") ^ SemanticActionFactory.DescAction(description: "Main Class") ^ MainCLassAction

let ClassDeclarationParser = ReservedParser("class") + IdentifierParser + OptParser(parser: ReservedParser("extends") + IdentifierParser) + ReservedParser("{") + RepVarDeclarationParser + RepMethodDeclarationParser + ReservedParser("}") ^ SemanticActionFactory.DescAction(description: "Class Declaration") ^ ClassDeclarationAction

let VarDeclarationParser = TypeParser + IdentifierParser + ReservedParser(";") ^ SemanticActionFactory.DescAction(description: "Variable Declaration") ^ VarDeclarationAction
let RepVarDeclarationParser = RepParser(parser: VarDeclarationParser, desc: "Variable Declarations")

let MethodDeclarationArgumentsParser = ExpParser(parser: TypeParser + IdentifierParser, separator: ReservedParser(","), desc: "Arguments") ^ MethodDeclarationArgumentsAction
let MethodDeclarationParser = ReservedParser("public") + TypeParser + IdentifierParser + ((ReservedParser("(") + MethodDeclarationArgumentsParser + ReservedParser(")")) ^! GroupAction) + ReservedParser("{") + RepVarDeclarationParser + RepStmtParser + ReservedParser("}") ^ SemanticActionFactory.DescAction(description: "Method Declaration") ^ MethodDeclarationAction
let RepMethodDeclarationParser = RepParser(parser: MethodDeclarationParser, desc: "Method Declarations")

/* Type Parsers */
let IntArrayTypeParser = ReservedParser("int") + ReservedParser("[") + ReservedParser("]") ^ SemanticActionFactory.DescAction(description: "New Int Array")

let TypeParser = IntArrayTypeParser | ReservedParser("boolean") | ReservedParser("int") | IdentifierParser ^ SemanticActionFactory.WrapAction(description: "Type")

/* Statement Parsers */
let CompoundStmtParser = ReservedParser("{") + RepStmtParser + ReservedParser("}") ^! GroupAction

let IfStmtParser = ReservedParser("if") + ExprGroupParser + StmtParser + ReservedParser("else") + StmtParser ^ SemanticActionFactory.DescAction(description: "If Statement") ^ IfStmtAction

let WhileStmtParser = ReservedParser("while") + ExprGroupParser + StmtParser ^ SemanticActionFactory.WrapAction(description: "While Statement")

let PrintStmtParser = ReservedParser("System.out.println") + ExprGroupParser + ReservedParser(";") ^ SemanticActionFactory.DescAction(description: "Print Statement") ^ PrintStmtAction

let AssignmentStmtParser = IdentifierParser + ReservedParser("=") + ExprParser + ReservedParser(";") ^ SemanticActionFactory.DescAction(description: "Assignment Statement") ^ AssignmentStmtAction

let SubscriptAssignmentStmtParser = IdentifierParser + ReservedParser("[") + ExprParser + ReservedParser("]") + ReservedParser("=") + ExprParser + ReservedParser(";") ^ SemanticActionFactory.WrapAction(description: "Subscript Assignment Statement")

let ReturnStmtParser = ReservedParser("return") + ExprParser + ReservedParser(";") ^ SemanticActionFactory.DescAction(description: "Return Statement") ^ ReturnStmtAction

// Lazy Statement Parser
func StmtParserGenerator() -> BaseParser {
    return CompoundStmtParser | IfStmtParser | WhileStmtParser | PrintStmtParser | AssignmentStmtParser | SubscriptAssignmentStmtParser | ReturnStmtParser
}
let StmtParser = ~StmtParserGenerator
let RepStmtParser = RepParser(parser: StmtParser, desc: "Statements")

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
func ConstructPrecedenceExprParser(precedence: [(opers: [String], type: OperatorType)], termParser: BaseParser) -> BaseParser {
    var parser = termParser
    for (opers, type) in precedence {
        switch type {
        case .PreOp:
            parser = OptParser(parser: OpsParser(opers: opers)) + parser ^! PreOpAction
        case .BiOp:
            parser = (parser * (OpsParser(opers: opers)) % {
                (partial: ParseResult, separator: ParseResult, new: ParseResult) -> ParseResult in
                partial.append(separator)
                partial.append(new)
                return partial
            }) ^! BiOpAction
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
let PrecedenceExprParser = ConstructPrecedenceExprParser(precedence: Precedence, termParser: ExprTermParser)

// Parser for left-recursion expressions
let SubscriptExprParser = ExprTermParser + ReservedParser("[") + ExprParser + ReservedParser("]") ^ SemanticActionFactory.WrapAction(description: "Subscript Expression")

let LengthExprParser = ExprTermParser + ReservedParser(".") + ReservedParser("length") ^ SemanticActionFactory.WrapAction(description: "Length Expression")

let MethodInvocationArgumentsParser = ExpParser(parser: ExprParser, separator: ReservedParser(","), desc: "Arguments")
let MethodInvocationExprParser = ExprTermParser + ReservedParser(".") + IdentifierParser + ReservedParser("(") + MethodInvocationArgumentsParser + ReservedParser(")") ^ SemanticActionFactory.DescAction(description: "Method Invocation Expression") ^ MethodInvocationExprAction

// Parser for non-left-recursion expressions
let IntLiteralParser = TagParser(.Int) ^ SemanticActionFactory.WrapAction(description: "Int Literal")

let NewIntArrayParser = ReservedParser("new") + ReservedParser("int") + ReservedParser("[") + ExprParser + ReservedParser("]") ^ SemanticActionFactory.WrapAction(description: "New Int Array")

let NewObjectParser = ReservedParser("new") + IdentifierParser + ReservedParser("(") + ReservedParser(")") ^ SemanticActionFactory.DescAction(description: "New Object Expression") ^ NewObjectAction

let ExprValueParser = IntLiteralParser | ReservedParser("true") | ReservedParser("false") | IdentifierParser | ReservedParser("this") | NewIntArrayParser | NewObjectParser

let ExprGroupParser = ReservedParser("(") + ExprParser + ReservedParser(")") ^! GroupAction

let ExprTermParser = ExprValueParser | ExprGroupParser

// Lazy Expression Parser
func ExprParserGenerator() -> BaseParser {
    return SubscriptExprParser | LengthExprParser | MethodInvocationExprParser | PrecedenceExprParser
}
let ExprParser = ~ExprParserGenerator

/* Identifier Parser */
let IdentifierParser = TagParser(.Id) ^ SemanticActionFactory.WrapAction(description: "Identifier")
