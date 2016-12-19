//
//  main.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

import Foundation

let tokenizer = Tokenizer()

let tokens = try! tokenizer.tokenize(material: "(2 + 2) * 6")

var env:[String: Any] = [:]
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

let parser = ArithExprParserProcessor()
let result = parser.parse(tokens: tokens, pos: 0)!
print(result.data.eval(environment: &env) as! Int)
