//
//  Visualize.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2017/12/19.
//  Copyright © 2017年 Nycshisan. All rights reserved.
//

import Foundation

extension BaseASTNode {
    func serialize() -> SerializableASTNode {
        var title = desc
        if token != nil {
            title += " - Token: \(token!.text)"
        }
        var serializedChildren: [SerializableASTNode] = []
        if children != nil {
            serializedChildren = children!.map { $0.serialize() }
        }
        return SerializableASTNode(title: title, children: serializedChildren)
    }
}

class SerializableASTNode: Codable {
    let icon = false
    var title: String
    var children: [SerializableASTNode]
    
    init(title: String, children: [SerializableASTNode]) {
        self.title = title
        self.children = children
    }
    
    func fillHTML(_ content: String) -> String {
        let HTMLContain = """
        <!doctype html>
        <head>
          <link href="www/skin-win8/ui.fancytree.min.css" rel="stylesheet">
          <script src="www/jquery-3.2.1.min.js"></script>
          <script src="www/jquery.fancytree-all-deps.min.js"></script>
          <script type="text/javascript">
            $(function(){
              $("#tree").fancytree({
                source: [\(content)]
              });
            });
          </script>
        </head>
        <body>
          <div id="tree"></div>
        </body>
        </html>
        """
        return HTMLContain
    }
    
    func visualizeToHTML(filename: String) {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(self)
            let JSONString = String.init(data: encoded, encoding: .utf8)
            writeFile(filename, content: fillHTML(JSONString!))
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
