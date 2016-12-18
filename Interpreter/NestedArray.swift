//
//  NestedArray.swift
//  Interpreter
//
//  Created by 陈十三 on 2016/12/17.
//  Copyright © 2016年 陈十三. All rights reserved.
//

import Foundation

struct NestedArray<Element> {
    let value: Element?
    var children: [NestedArray]?
    
    init() {
        self.value = nil
        self.children = []
    }
    
    init(value: NestedArray) {
        self.value = nil
        self.children = [value]
    }
    
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

extension NestedArray where Element: Equatable {
    static func == (lhs: NestedArray, rhs: NestedArray) -> Bool {
        if lhs.value != nil && rhs.value != nil {
            return lhs.value! == rhs.value!
        } else if lhs.children != nil && rhs.children != nil {
            let count = lhs.children!.count
            if rhs.children!.count != count {
                return false
            } else {
                for i in 0 ..< count {
                    if lhs.children![i] != rhs.children![i] {
                        return false
                    }
                }
                return true
            }
        } else {
            return false
        }
    }
    
    static func != (lhs: NestedArray, rhs: NestedArray) -> Bool {
        return !(lhs == rhs)
    }
}
