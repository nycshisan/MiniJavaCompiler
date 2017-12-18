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
class BaseParser {
    func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        fatalError("virtual parse function is invoked")
    }

    func throwError(tokens: inout [Token], pos: Int, errorInfo: String) {
        if pos < tokens.count {
            let error = SCError(code: ExpectedUnconformityError, info: errorInfo, token: tokens[pos])
            error.print()
        }
    }
}

/* Some sugar for parser combinators */
func + (left: BaseParser, right: BaseParser) -> ConcatParser {
    return ConcatParser(left: left, right: right)
}

func * (left: BaseParser, right: BaseParser) -> ExpParser {
    return ExpParser(parser: left, separator: right)
}

func | (left: BaseParser, right: BaseParser) -> BaseParser {
    return AlternateParser(left: left, right: right)
}

func ^ (left: BaseParser, right: @escaping ProcessParser.Processor) -> ProcessParser {
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

prefix func ~ (generator: @escaping () -> BaseParser) -> BaseParser {
    return LazyParser(generator: generator)
}

/* Combinators */
class ReservedParser: BaseParser {
    // Parser for reversed words
    let word: String
    let tag: TokenTag
    
    init(_ word: String, tag: TokenTag = .Reserved) {
        self.word = word
        self.tag = tag
    }
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        if pos < tokens.count && tokens[pos].text == word && tokens[pos].tag == tag {
            let result = ParseResult(token: tokens[pos], pos: pos + 1)
            result.desc = tokens[pos].text
            return result
        } else {
            return nil
        }
    }
}

class TagParser: BaseParser {
    // Parser for tokens of specific tags
    let tag: TokenTag
    
    init(_ tag: TokenTag) {
        self.tag = tag
    }
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        if pos < tokens.count && tokens[pos].tag == tag {
            let result = ParseResult(token: tokens[pos], pos: pos + 1)
            result.desc = tokens[pos].text
            return result
        } else {
            return nil
        }
    }
}

class ConcatParser: BaseParser {
    // Parser to concatenate two component parser, which should all be parsed successfully
    let left, right: BaseParser
    
    init(left: BaseParser, right: BaseParser) {
        self.left = left
        self.right = right
    }
    
    func flattenParse(parser: BaseParser, tokens: inout [Token], pos: Int) -> [ParseResult]? {
        if let result = parser.parse(tokens: &tokens, pos: pos) {
            if parser is ConcatParser && result.children != nil {
                return result.children
            } else {
                return [result]
            }
        } else {
            return nil
        }
    }
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        if let leftResult = flattenParse(parser: left, tokens: &tokens, pos: pos) {
            if let rightResult = flattenParse(parser: right, tokens: &tokens, pos: leftResult.last!.pos) {
                return ParseResult(children: leftResult + rightResult, pos: rightResult.last!.pos)
            } else {
                // right parser error
                return nil
            }
        } else {
            // left parser error
            return nil
        }
    }
    
}

class ExpParser: BaseParser {
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
    
    let parser: BaseParser
    let separator: BaseParser
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
    
    init(parser: BaseParser, separator: BaseParser) {
        self.parser = parser
        self.separator = separator
    }
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        if var result = (parser ^ initializer).parse(tokens: &tokens, pos: pos) {
            let nextParser = separator + parser
            
            while let nextResult = nextParser.parse(tokens: &tokens, pos: result.pos) {
                let separatorResult = nextResult[0]
                let parseResult = nextResult[1]
                result = processor(result, separatorResult, parseResult)
                result.pos = nextResult.pos
            }
            return result
        } else {
            return nil
        }
    }
}

class AlternateParser: BaseParser {
    // Parser to concatenate two component parser, and the first parser will cover the second one if the former succeeds
    let left, right: BaseParser
    
    init(left: BaseParser, right: BaseParser) {
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

class ProcessParser: BaseParser {
    // Wrapped parser which will return a processed result after successfully parsing, similar to semantic actions
    typealias Processor = (ParseResult) -> ParseResult
    
    let parser: BaseParser
    let processor: Processor
    
    init(parser: BaseParser, processor: @escaping Processor) {
        self.parser = parser
        self.processor = processor
    }
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        if var result = parser.parse(tokens: &tokens, pos: pos) {
            result = processor(result)
            return result
        } else {
            return nil
        }
    }
}

class OptParser: BaseParser {
    // Optional parser which will cause no effect when parsing failing
    let parser: BaseParser
    
    init(parser: BaseParser) {
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

class RepParser: BaseParser {
    // Greed parser which will parse as much tokens as possible repeatedly
    let parser: BaseParser
    
    init(parser: BaseParser) {
        self.parser = parser
    }
    
    override func parse(tokens: inout [Token], pos: Int) -> ParseResult? {
        var results: [ParseResult] = []
        var crtPos = pos
        repeat {
            if let result = parser.parse(tokens: &tokens, pos: crtPos) {
                results.append(result)
                crtPos = result.pos
            } else {
                break
            }
        } while (true)
        return ParseResult(children: results, pos: crtPos)
    }
}

class LazyParser: BaseParser {
    // Lazy parser to avoid infinite recursion
    let generator: () -> BaseParser
    
    init(generator: @escaping () -> BaseParser) {
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

class PhraseParser: BaseParser {
    // Parser which will only succeed when exhaust all tokens
    let parser: BaseParser
    
    init(parser: BaseParser) {
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
