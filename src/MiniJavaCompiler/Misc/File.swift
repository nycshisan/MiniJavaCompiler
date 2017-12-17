//
//  File.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2017/12/16.
//  Copyright © 2017年 Nycshisan. All rights reserved.
//

import Foundation

func openFile(_ filename: String) -> String? {
    do {
        return try String.init(contentsOfFile: filename)
    } catch let error as NSError {
        print(error.localizedDescription)
        return nil
    }
}
