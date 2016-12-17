//
//  DataStructure.swift
//  Interpreter
//
//  Created by 陈十三 on 2016/12/17.
//  Copyright © 2016年 陈十三. All rights reserved.
//

import Foundation

struct NestedArray<Element> {
    let value: Element?
    var children: [NestedArray]?
    
    init(value: Element) {
        self.value = value
        self.children = nil
    }
    
    init(values: [NestedArray]) {
        self.value = nil
        self.children = values
    }
    
    init(values: [Element]) {
        self.value = nil
        self.children = values.map { value in NestedArray(value: value) }
    }
    
    subscript(index: Int) -> NestedArray? {
        return children?[index]
    }
    
    mutating func append(element: NestedArray<Element>) -> Bool {
        if children != nil {
            children!.append(element)
            return true
        } else {
            return false
        }
    }
}
