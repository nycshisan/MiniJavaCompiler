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
    convenience init(values: [String]) {
        let children = values.map { value in ASTNode(value: value) }
        self.init(values: children)
    }
    
    static func == (lhs: ASTNode, rhs: ASTNode) -> Bool {
        if lhs.value != nil && rhs.value != nil {
            return lhs.value! == rhs.value!
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
    
    var nestedArray: ASTNode!
    
    override func setUp() {
        nestedArray = ASTNode(values: ["asd", "qwe"])
        nestedArray.append(element: ASTNode(value: "zxc"))
    }
    
    override func tearDown() {
        
    }
    
    func testEqual() {
        var expected = ASTNode(value: "zxc")
        var actual = nestedArray[2]
        XCTAssertTrue(actual == expected)
        expected = nestedArray
        actual = ASTNode(values: ["asd", "qwe"])
        actual.append(element: ASTNode(value: "zxc"))
        XCTAssertTrue(actual == expected)
    }
    
}
