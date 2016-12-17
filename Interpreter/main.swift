//
//  main.swift
//  Interpreter
//
//  Created by 陈十三 on 2016/12/17.
//  Copyright © 2016年 陈十三. All rights reserved.
//

import Foundation

let lexer = Lexer(material: "a = 2\nb=3\nc = a+ b\n++a\nprint a")

try! lexer.lex()

debugPrint(lexer.tokens)
