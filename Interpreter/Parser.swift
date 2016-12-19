//
//  Parser.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/19.
//  Copyright © 2016年 陈十三. All rights reserved.
//

/* Arithmetic Expressions Parsers */
func ArithExprParserProcessor() -> Parser {
    func OpsParser(opers: [String]) -> ProcessParser {
        var parsers = opers.map({ ReservedParser(word: $0) })
        let initial = parsers.removeFirst()
        let parser = parsers.reduce(initial) { $0 | $1 }
        return parser ^ {
            (data: ParseResult.Value) -> ParseResult.Value in
            let left = data[0] as! ArithExpr
            let oper = data[1].value!
            let right = data[2] as! ArithExpr
            return ParseResult.Value(values: [ArithBiOpExpr(oper: oper, left: left, right: right)] )
        }
    }
    
    var ArithOpPrecedence = [
        ["*", "/"],
        ["+", "-"]
    ]
    
    let firstPrecedence = ArithOpPrecedence.removeFirst()
    let initialParser = ArithTermParser * OpsParser(opers: firstPrecedence)
    let parser = ArithOpPrecedence.reduce(initialParser) {
        (partialResult: Parser, nextPrecedence: [String]) -> Parser in
        return partialResult * OpsParser(opers: nextPrecedence)
    }
    return parser
}

let IntExprParser = TagParser(tag: .Int) ^ { IntExpr($0) }

let VarExprParser = TagParser(tag: .Id) ^ { VarExpr($0) }

let ArithValueParser = IntExprParser | VarExprParser

let ArithGroupParser = ReservedParser(word: "(") + ~ArithExprParserProcessor + ReservedParser(word: ")") ^ { $0[0][1] }

let ArithTermParser = ArithValueParser | ArithGroupParser
