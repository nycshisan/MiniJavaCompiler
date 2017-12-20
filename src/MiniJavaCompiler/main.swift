//
//  main.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

import Foundation

let DEBUG_FILENAME: String? = "SamplePrograms/factorial.java"

// read file and setup context
var commandLineArguments = CommandLineArguments()
commandLineArguments.parseArgs()
guard let text = openFile(DEBUG_FILENAME ?? commandLineArguments.filename!) else {
    exit(EXIT_FAILURE)
}
SCError.material = text

// Tokenizing
let tokenizer = Tokenizer()
var tokens = tokenizer.forceTokenize(material: text)

// Grammar Parsing
guard let parseResult = GoalParser.parse(tokens: &tokens, pos: 0) else {
    let token = tokens[DEBUG_MAX_POS]
    let error = SCError(code: UnknownError, info: "Parse Error on Token \(DEBUG_MAX_POS) - \(token.text)", token: token)
    error.print()
    exit(EXIT_FAILURE)
}

// Visualization
let outFilename = commandLineArguments.filename! + ".html"
parseResult.serialize().visualizeToHTML(filename: outFilename)
print("Outputted to \(outFilename)")
