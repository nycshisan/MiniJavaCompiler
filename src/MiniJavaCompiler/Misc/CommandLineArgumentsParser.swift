//
//  CommandLineArgumentsParser.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2017/12/16.
//  Copyright © 2017年 陈十三. All rights reserved.
//

import Foundation

class CommandLineArguments {
    var filename: String?
    
    func parseArgs() {
        let args = CommandLine.arguments
        self.filename = args.last
    }
}
