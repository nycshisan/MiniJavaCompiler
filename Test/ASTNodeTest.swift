//
//  NestedArrayTest.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/18.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

import XCTest

// Extensions for debugging
extension ASTNode: Equatable {
    convenience init(children: [String]) {
        let children = children.map { child in ASTNode(token: Token(text: child)) }
        self.init(children: children)
    }
    
    static func == (lhs: ASTNode, rhs: ASTNode) -> Bool {
        if lhs.token != nil && rhs.token != nil {
            return lhs.token!.text == rhs.token!.text
        }
        if lhs.children != nil && rhs.children != nil && lhs.children!.count == rhs.children!.count {
            for i in 0 ..< lhs.children!.count {
                if lhs.children![i] != rhs.children![i] {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    static func != (lhs: ASTNode, rhs: ASTNode) -> Bool {
        return !(lhs == rhs)
    }
}

class ASTNodeTest: XCTestCase {
    
    var node: ASTNode!
    
    override func setUp() {
        node = ASTNode(children: ["asd", "qwe"])
        node.append(element: ASTNode(token: Token(text: "zxc")))
    }
    
    override func tearDown() {
        
    }
    
    func testEqual() {
        var expected = ASTNode(token: Token(text: "zxc"))
        var actual = node[2]
        XCTAssertTrue(actual == expected)
        expected = node
        actual = ASTNode(children: ["asd", "qwe"])
        actual.append(element: ASTNode(token: Token(text: "zxc")))
        XCTAssertTrue(actual == expected)
    }
    
}
