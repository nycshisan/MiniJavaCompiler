//
//  ParserCombinations.swift
//  Interpreter
//
//  Created by 陈十三 on 2016/12/17.
//  Copyright © 2016年 陈十三. All rights reserved.
//

import Foundation

/* Base Parser */
class Parser {
    
    func parse(tokens: [Token], pos: Int) -> ParseResult? {
        return nil
    }
    
    static func + (left: Parser, right: Parser) -> Parser {
        return ConcatParser(left: left, right: right)
    }
    
    static func * (left: Parser, right: Parser) -> Parser {
        return ExpParser(parser: left, separator: right)
    }
    
    static func | (left: Parser, right: Parser) -> Parser {
        return AlternateParser(left: left, right: right)
    }
    
    static func ^ (left: Parser, right: @escaping ProcessParser.Processor) -> Parser {
        return ProcessParser(parser: left, processor: right)
    }
 
}


/* Combinations */
class ReservedParser: Parser {
    // Parser for reversed words
    let word: String
    let tag: TokenTag = .Reserved
    
    init(word: String) {
        self.word = word
    }
    
    override func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if pos < tokens.count && tokens[pos].text == word && tokens[pos].tag == tag {
            return ParseResult(value: tokens[pos].text, pos: pos + 1)
        } else {
            return nil
        }
    }
}

class TagParser: Parser {
    // Parser for tokens of specific tags
    let tag: TokenTag
    
    init(tag: TokenTag) {
        self.tag = tag
    }
    
    override func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if pos < tokens.count && tokens[pos].tag == tag {
            return ParseResult(value: tokens[pos].text, pos: pos + 1)
        } else {
            return nil
        }
    }
}

class ConcatParser: Parser {
    // Parser to concatenate two component parser, which should all be parsed successfully
    let left, right: Parser
    
    init(left: Parser, right: Parser) {
        self.left = left
        self.right = right
    }
    
    override func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if let leftResult = left.parse(tokens: tokens, pos: pos) {
            if let rightResult = right.parse(tokens: tokens, pos: leftResult.pos) {
                return ParseResult(values: [leftResult.value, rightResult.value], pos: rightResult.pos)
            }
        }
        return nil
    }
    
}

class ExpParser: Parser {
    // Parser to parse a combination of tokens
    let parser, separator: Parser
    
    init(parser: Parser, separator: Parser) {
        self.parser = parser
        self.separator = separator
    }
    
    func prepareFirst(value: ParseResult.Value) -> ParseResult.Value {
        // Convert the first parse result value to an array for appending
        return ParseResult.Value(values: [value])
    }
    
    override func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if var result = (parser ^ prepareFirst).parse(tokens: tokens, pos: pos) {
            func processNext(lastResultValue: ParseResult.Value) -> ParseResult.Value {
                var resultValue = result.value
                let flag = resultValue.append(element: lastResultValue[1]!)
                assert(flag)
                return resultValue
            }
            let nextParser = separator + self.parser ^ processNext
            
            while true {
                if let nextResult = nextParser.parse(tokens: tokens, pos: result.pos) {
                    result = nextResult
                } else {
                    break
                }
            }
            return result
        } else {
            return nil
        }
    }
}

class AlternateParser: Parser {
    // Parser to concatenate two component parser, and the first parser will cover the second one if the former succeeds
    let left, right: Parser
    
    init(left: Parser, right: Parser) {
        self.left = left
        self.right = right
    }
    
    override func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if let leftResult = left.parse(tokens: tokens, pos: pos) {
            return leftResult
        } else {
            let rightResult = right.parse(tokens: tokens, pos: pos)
            return rightResult
        }
    }
}

class ProcessParser: Parser {
    // Wrapped parser which will return a processed result after successfully parsing
    typealias Processor = (ParseResult.Value) -> ParseResult.Value
    
    let parser: Parser
    let processor: Processor
    
    init(parser: Parser, processor: @escaping Processor) {
        self.parser = parser
        self.processor = processor
    }
    
    override func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if let result = parser.parse(tokens: tokens, pos: pos) {
            result.value = processor(result.value)
            return result
        } else {
            return nil
        }
    }
}

class OptParser: Parser {
    // Optional parser which will cause no effect when parsing failing
    let parser: Parser
    
    init(parser: Parser) {
        self.parser = parser
    }
    
    override func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if let result = parser.parse(tokens: tokens, pos: pos) {
            return result
        } else {
            return ParseResult(value: "Null", pos: pos)
        }
    }
}

class RepParser: Parser {
    // Greed parser which will parse as much tokens as possible repeatedly
    let parser: Parser
    
    init(parser: Parser) {
        self.parser = parser
    }
    
    override func parse(tokens: [Token], pos: Int) -> ParseResult? {
        var results: [ParseResult.Value] = []
        var crtPos = pos
        repeat {
            if let result = parser.parse(tokens: tokens, pos: crtPos) {
                results.append(result.value)
                crtPos = result.pos
            } else {
                break
            }
        } while (true)
        return ParseResult(values: results, pos: crtPos)
    }
}

class PhraseParser: Parser {
    // Parser which will only succeed when exhaust all tokens
    let parser: Parser
    
    init(parser: Parser) {
        self.parser = parser
    }
    
    override func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if let result = parser.parse(tokens: tokens, pos: pos) {
            if result.pos == tokens.count {
                return result
            }
        }
        return nil
    }
}

/* Parser Result Class */
class ParseResult {
    typealias Value = NestedArray<String>
    
    var value: Value
    let pos: Int
    
    init(value: String, pos: Int) {
        self.value = Value(value: value)
        self.pos = pos
    }
    
    init(value: Value, pos: Int) {
        self.value = value
        self.pos = pos
    }
    
    init(values: [Value], pos: Int) {
        self.value = Value(values: values)
        self.pos = pos
    }
}
