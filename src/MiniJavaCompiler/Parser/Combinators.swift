//
//  Combinators.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

import Foundation

typealias ParseResult = BaseASTNode

/* Base Grammar Parser */
class Parser {
    func parse(tokens: inout [Token], pos: Int) -> ParseResult? { return nil }

    func throwError(tokens: inout [Token], pos: Int, errorInfo: String) {
        if pos < tokens.count {
            let error = SCError(code: ExpectedUnconformityError, info: errorInfo, token: tokens[pos])
            error.print()
        }
    }
}

/* Some sugar for parser combinators */
func + (left: Parser, right: Parser) -> ConcatParser {
    return ConcatParser(left: left, right: right)
}

func * (left: Parser, right: Parser) -> ExpParser {
    return ExpParser(parser: left, separator: right)
}

func | (left: Parser, right: Parser) -> Parser {
    return AlternateParser(left: left, right: right)
}

func ^ (left: Parser, right: @escaping ProcessParser.Processor) -> ProcessParser {
    return ProcessParser(parser: left, processor: right)
}

func % (left: ExpParser, right: @escaping ExpParser.Processor) -> ExpParser {
    left.processor = right
    return left
}

func % (left: ExpParser, right: (ExpParser.Initializer, ExpParser.Processor)) -> ExpParser {
    left.initializer = right.0
    left.processor = right.1
    return left
}

prefix func ~ (generator: @escaping () -> Parser) -> Parser {
    return LazyParser(generator: generator)
}

/* Combinators */
class ReservedParser: Parser {
    // Parser for reversed words
    let word: String
    let tag: TokenTag
    
    init(word: String, tag: TokenTag = .Reserved) {
        self.word = word
        self.tag = tag
    }
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
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
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
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
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        if let leftResult = left.parse(tokens: &tokens, pos: pos) {
            if let rightResult = right.parse(tokens: &tokens, pos: leftResult.pos) {
                return ParseResult(children: [leftResult, rightResult], pos: rightResult.pos)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
}

class ExpParser: Parser {
    // Parser to parse a combinator of tokens
    typealias Processor = (ParseResult, ParseResult, ParseResult) -> ParseResult
    /*
     ExpParser.processor must accect an array like [partial, separator, new]
     and return reduced result for next loop
     */
    typealias Initializer = ProcessParser.Processor
    /*
     ExpParser.initializer must accept the first parse result and return the first partial result
     */
    
    let parser: Parser
    let separator: Parser
    var processor: Processor =  {
        (partial: ParseResult, separator: ParseResult, new: ParseResult) -> ParseResult in
        // Default processor, discard the separator's result and append the parse result to result array.
        partial.append(new)
        return partial
    }
    var initializer: Initializer = {
        (value: ParseResult) -> ParseResult in
        // Default initializer, convert the first parse result value to an array for appending
        return ParseResult(children: [value], pos: value.pos)
    }
    
    init(parser: Parser, separator: Parser) {
        self.parser = parser
        self.separator = separator
    }
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        if let result = (parser ^ initializer).parse(tokens: &tokens, pos: pos) {
            let nextParser = separator + parser
            
            while let nextResult = nextParser.parse(tokens: &tokens, pos: result.pos) {
                let separatorResult = nextResult[0]
                let parseResult = nextResult[1]
                result.node = processor(result.node, separatorResult, parseResult)
                result.pos = nextResult.pos
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
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        if let leftResult = left.parse(tokens: &tokens, pos: pos) {
            return leftResult
        } else {
            let rightResult = right.parse(tokens: &tokens, pos: pos)
            if rightResult == nil {
            }
            return rightResult
        }
    }
}

class ProcessParser: Parser {
    // Wrapped parser which will return a processed result after successfully parsing
    typealias Processor = (ParseResult) -> ParseResult
    
    let parser: Parser
    let processor: Processor
    
    init(parser: Parser, processor: @escaping Processor) {
        self.parser = parser
        self.processor = processor
    }
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        if let result = parser.parse(tokens: &tokens, pos: pos) {
            result = processor(result.node)
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
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        if let result = parser.parse(tokens: &tokens, pos: pos) {
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
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        var results: [ParseResult] = []
        var crtPos = pos
        repeat {
            if let result = parser.parse(tokens: &tokens, pos: crtPos) {
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
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        let parser = generator()
        let result = parser.parse(tokens: &tokens, pos: pos)
        if result == nil {
        }
        return result
    }
}

class PhraseParser: Parser {
    // Parser which will only succeed when exhaust all tokens
    let parser: Parser
    
    init(parser: Parser) {
        self.parser = parser
    }
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        if let result = parser.parse(tokens: &tokens, pos: pos) {
            if result.pos == tokens.count {
                return result
            } else {
                let error = SCError(code: TokenNotExhaustedError, info: "Tokens are not exhausted", token: tokens[result.pos])
                error.print()
            }
        }
        exit(TokenNotExhaustedError)
    }
}
