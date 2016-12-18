//
//  NestedArrayTest.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/18.
//  Copyright © 2016年 陈十三. All rights reserved.
//

import XCTest

class NestedArrayTest: XCTestCase {
    
    var nestedArray: NestedArray<String>!
    
    override func setUp() {
        nestedArray = NestedArray<String>(values: ["asd", "qwe"])
        XCTAssertTrue(nestedArray.append(element: NestedArray<String>(value: "zxc")))
    }
    
    override func tearDown() {
        
    }
    
    func testEqual() {
        var expected = NestedArray<String>(value: "zxc")
        var actual = nestedArray[2]
        XCTAssertTrue(actual! == expected)
        expected = nestedArray
        actual = NestedArray<String>(values: ["asd", "qwe"])
        XCTAssertTrue(actual!.append(element: NestedArray<String>(value: "zxc")))
        XCTAssertTrue(actual! == expected)
    }
    
}
