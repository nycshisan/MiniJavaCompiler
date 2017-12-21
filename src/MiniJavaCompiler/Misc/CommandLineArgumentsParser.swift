//
//  CommandLineArgumentsParser.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2017/12/16.
//  Copyright © 2017年 Nycshisan. All rights reserved.
//

import Foundation

class CommandLineArguments {
    var filename: String?
    
    func parseArgs() {
        let args = CommandLine.arguments
        
        if args.contains("--CST") {
            SemanticActionParser.DEBUG_DISABLE_SEMANTIC_ACTION = true
        }
        
        self.filename = args.last
    }
}
