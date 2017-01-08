//
//  Combinations.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

/* Base Parser */
protocol Parser {
    
    func parse(tokens: [Token], pos: Int) -> ParseResult?
 
}

/* Some sugar for parser combinations */
func + (left: Parser, right: Parser) -> Parser {
    return ConcatParser(left: left, right: right)
}

func * (left: Parser, right: ProcessParser) -> Parser {
    return ExpParser(parser: left, separator: right)
}

func | (left: Parser, right: Parser) -> Parser {
    return AlternateParser(left: left, right: right)
}

func ^ (left: Parser, right: @escaping ProcessParser.Processor) -> ProcessParser {
    return ProcessParser(parser: left, processor: right)
}

prefix func ~ (generator: @escaping () -> Parser) -> Parser {
    return LazyParser(generator: generator)
}

/* Combinations */
class ReservedParser: Parser {
    // Parser for reversed words
    let word: String
    let tag: TokenTag = .Reserved
    
    init(word: String) {
        self.word = word
    }
    
    func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if pos < tokens.count && tokens[pos].text == word && tokens[pos].tag == tag {
            return ParseResult(token: tokens[pos], pos: pos + 1)
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
    
    func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if pos < tokens.count && tokens[pos].tag == tag {
            return ParseResult(token: tokens[pos], pos: pos + 1)
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
    
    func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if let leftResult = left.parse(tokens: tokens, pos: pos) {
            if let rightResult = right.parse(tokens: tokens, pos: leftResult.pos) {
                return ParseResult(children: [leftResult.node, rightResult.node], pos: rightResult.pos)
            }
        }
        return nil
    }
    
}

class ExpParser: Parser {
    // Parser to parse a combination of tokens
    let parser: Parser
    let separator: Parser
    let processor: ProcessParser.Processor
    
    init(parser: Parser, separator: ProcessParser) {
        /*
         ExpParser.processor must accect an array like [partialResult, separator, newResult]
         and return reducedResult for next appending
         */
        self.parser = parser
        self.separator = separator.parser
        self.processor = separator.processor
    }
    
    func prepareFirst(value: ParseResult.Node) -> ParseResult.Node {
        // Convert the first parse result value to an array for appending
        return ParseResult.Node(children: [value])
    }
    
    func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if let result = (parser ^ prepareFirst).parse(tokens: tokens, pos: pos) {
            let nextParser = separator + parser
            
            while let nextResult = nextParser.parse(tokens: tokens, pos: result.pos) {
                result.node.children! += nextResult.node.children! // Append new result
                result.node = ParseResult.Node(children: [processor(result.node)])
                result.pos = nextResult.pos
            }
            
            // Unwrap the result
            result.node = result.node[0]
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
    
    func parse(tokens: [Token], pos: Int) -> ParseResult? {
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
    typealias Processor = (ParseResult.Node) -> ParseResult.Node
    
    let parser: Parser
    let processor: Processor
    
    init(parser: Parser, processor: @escaping Processor) {
        self.parser = parser
        self.processor = processor
    }
    
    func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if let result = parser.parse(tokens: tokens, pos: pos) {
            result.node = processor(result.node)
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
    
    func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if let result = parser.parse(tokens: tokens, pos: pos) {
            return result
        } else {
            return ParseResult(token: nil, pos: pos)
        }
    }
}

class RepParser: Parser {
    // Greed parser which will parse as much tokens as possible repeatedly
    let parser: Parser
    
    init(parser: Parser) {
        self.parser = parser
    }
    
    func parse(tokens: [Token], pos: Int) -> ParseResult? {
        var results: [ParseResult.Node] = []
        var crtPos = pos
        repeat {
            if let result = parser.parse(tokens: tokens, pos: crtPos) {
                results.append(result.node)
                crtPos = result.pos
            } else {
                break
            }
        } while (true)
        return ParseResult(children: results, pos: crtPos)
    }
}

class LazyParser: Parser {
    // Lazy parser to avoid infinite recursion
    let generator: () -> Parser
    
    init(generator: @escaping () -> Parser) {
        self.generator = generator
    }
    
    func parse(tokens: [Token], pos: Int) -> ParseResult? {
        let parser = generator()
        return parser.parse(tokens: tokens, pos: pos)
    }
}

class PhraseParser: Parser {
    // Parser which will only succeed when exhaust all tokens
    let parser: Parser
    
    init(parser: Parser) {
        self.parser = parser
    }
    
    func parse(tokens: [Token], pos: Int) -> ParseResult? {
        if let result = parser.parse(tokens: tokens, pos: pos) {
            if result.pos == tokens.count {
                return result
            }
        }
        return nil
    }
}
