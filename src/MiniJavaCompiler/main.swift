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


let n = SerializableASTNode(title: "123", children: [])
n.visualizeToHTML(filename: "test.html")
exit(3)


// read file and setup context
var commandLineArguments = CommandLineArguments()
commandLineArguments.parseArgs()
guard let text = openFile(commandLineArguments.filename!) else {
    exit(EXIT_FAILURE)
}
SCError.material = text


let tokenizer = Tokenizer()
let tokens = tokenizer.forceTokenize(material: text)
