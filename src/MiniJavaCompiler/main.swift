//
//  main.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

import Foundation

//let tokenizer = Tokenizer()
//
//let material = "i = 0;" + "\n" +
//            "while (!(i > 100)) {" + "\n" +
//            "i = i + 1;" + "\n" +
//            "};" + "\n" +
//            "print i;"
//
//SCError.material = material
//let tokens = tokenizer.tokenizeCaughtError(material: material)
//
//var env: [String: Any] = [:]
//
//env["+"] = {
//    (left: Any, right: Any) -> Any in
//    let l = left as! Int
//    let r = right as! Int
//    return l + r
//}
//env["-"] = {
//    (left: Any, right: Any) -> Any in
//    let l = left as! Int
//    let r = right as! Int
//    return l - r
//}
//env["*"] = {
//    (left: Any, right: Any) -> Any in
//    let l = left as! Int
//    let r = right as! Int
//    return l * r
//}
//env["/"] = {
//    (left: Any, right: Any) -> Any in
//    let l = left as! Int
//    let r = right as! Int
//    return l / r
//}
//env[">"] = {
//    (left: Any, right: Any) -> Any in
//    let l = left as! Int
//    let r = right as! Int
//    return l > r
//}
//env["<"] = {
//    (left: Any, right: Any) -> Any in
//    let l = left as! Int
//    let r = right as! Int
//    return l < r
//}
//env["&&"] = {
//    (left: Any, right: Any) -> Any in
//    let l = left as! Bool
//    let r = right as! Bool
//    return l && r
//}
//env["||"] = {
//    (left: Any, right: Any) -> Any in
//    let l = left as! Bool
//    let r = right as! Bool
//    return l || r
//}
//env["!"] = {
//    (old: Any) -> Any in
//    let oldBool = old as! Bool
//    return !oldBool
//}
//
//let result = MainParser.parse(tokens: tokens, pos: 0)!
//let _ = result.node.eval(environment: &env)

var commandLineArguments = CommandLineArguments()
commandLineArguments.parseArgs()
let text = openFile(commandLineArguments.filename!)
if (text == nil) {
    exit(EXIT_FAILURE)
}
print(text)
