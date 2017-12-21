//
//  main.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

import Foundation

let DEBUG_FILENAME: String? = "SamplePrograms/cyc1.java"

// read file and setup context
var commandLineArguments = CommandLineArguments()
commandLineArguments.parseArgs()
guard let text = openFile(DEBUG_FILENAME ?? commandLineArguments.filename!) else {
    exit(EXIT_FAILURE)
}
SCError.material = text

// Tokenizing
let tokenizer = Tokenizer()
guard var tokens = tokenizer.tokenize(material: text) else {
    exit(EXIT_FAILURE)
}

// Grammar Parsing
guard let parseResult = GoalParser.parse(tokens: &tokens, pos: 0) else {
//    let token = tokens[MaxPos]
//    let error = SCError(code: UnknownError, info: "Parse Error on Token \(MaxPos) - \(token.text)", token: token)
//    error.print()
    exit(EXIT_FAILURE)
}

// Visualization
let outFilename = commandLineArguments.filename! + ".html"
parseResult.serialize().visualizeToHTML(filename: outFilename)
print("Outputted to \(outFilename)")
