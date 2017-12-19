//
//  main.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

import Foundation

// read file and setup context
var commandLineArguments = CommandLineArguments()
commandLineArguments.parseArgs()
guard let text = openFile(commandLineArguments.filename!) else {
    exit(EXIT_FAILURE)
}
SCError.material = text

// Tokenizing
let tokenizer = Tokenizer()
var tokens = tokenizer.forceTokenize(material: text)

// Grammar Parsing
let parseResult = GoalParser.parse(tokens: &tokens, pos: 0)


// Visualization
let outFilename = commandLineArguments.filename! + ".html"
parseResult!.serialize().visualizeToHTML(filename: outFilename)
