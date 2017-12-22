//
//  main.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

import Foundation

let DEBUG_FILENAME: String? = nil

// read file and setup context
var commandLineArguments = CommandLineArguments()
commandLineArguments.parseArgs()
guard let text = openFile(DEBUG_FILENAME ?? commandLineArguments.filename!) else {
    exit(EXIT_FAILURE)
}
MJCError.material = text

// Tokenizing
let tokenizer = Tokenizer()
guard var tokens = tokenizer.tokenize(material: text) else {
    exit(EXIT_FAILURE)
}

// Grammar Parsing
guard let parseResult = GoalParser.parse(tokens: &tokens, pos: 0) else {
    exit(EXIT_FAILURE)
}

// Visualization
let outFilename = commandLineArguments.filename! + ".html"
parseResult.serialize().visualizeToHTML(filename: outFilename)
print("Outputted to \(outFilename)")

// Semantic analyzing
let analyzer = SemanticAnalyzer(root: parseResult)
guard analyzer.analyze() else {
    exit(EXIT_FAILURE)
}

// Emulation
if commandLineArguments.emulate {
    let emulator = Emulator(analyzer: analyzer, root: parseResult)
    emulator.emulate()
}
