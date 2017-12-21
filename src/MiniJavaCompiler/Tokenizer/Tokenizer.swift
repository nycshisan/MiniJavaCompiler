//
//  Tokenizer.swift
//  MiniJavaCompiler
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

import Foundation

/* Tokenizer Configs */
let ReservedWords = [
                    "class", "public", "static", "void", "main", "String", "extends",
                    "return", "int", "boolean", "if", "else", "while", "System.out.println",
                    "length", "true", "false", "this", "new"
                    ]

let SpecialReservedWords = [
    "System.out.println"
]

var ReservedRegExpPattern: String {
    return SpecialReservedWords.map({ word in "(\(word))" }).joined(separator: "|")
}

let TokenExpressions: [(pattern: String, tag: TokenTag)] = [
    ("//.*$", .None), // Comments
    ("\\s+", .None), // Blanks
    ("[+\\-*<&!=\\.]+", .Reserved), // Operators
    ("[(){},;\\[\\]]", .Reserved), // Delimiters
    (ReservedRegExpPattern, .Reserved), // Special Reversed words
    ("[A-Za-z_][A-Za-z0-9_]*", .Id), // Identifies
    ("[0-9]+", .Int), // Intergers
]

enum TokenTag {
    case Reserved
    case Separator
    case Int
    case Id
    case None
}


/* Token type */
class Token {
    let text: String
    var tag: TokenTag
    let position: Int
    let lineNum: Int
    
    init(text: String = "", tag: TokenTag = .None, position: Int = 0, lineNum: Int = 0) {
        self.text = text
        self.tag = tag
        self.position = position
        self.lineNum = lineNum
    }
}

/* Tokenizer Class */
class Tokenizer {
    var tokenRegExprs: [(re: NSRegularExpression, tag: TokenTag)] = []
    
    init() {
        // Prepare Regular Expressions
        for expr in TokenExpressions {
            do {
                let re = try NSRegularExpression(pattern: expr.pattern, options: NSRegularExpression.Options.anchorsMatchLines)
                tokenRegExprs.append((re, expr.tag))
            } catch {
                print("Internal Error of Tokenizer Regular Expressions: \(error.localizedDescription)")
                exit(EXIT_FAILURE)
            }
        }
    }
    
    func tokenize(material: String) -> [Token]? {
        var material = material
        var success = true
        
        var tokens: [Token] = []
        var lineNum = 0
        var position = 0
        
        // some variables for error recovery
        var lastLength = 0
        var errorNumberInCurrentLine = 0
        
        var range = NSMakeRange(0, material.count)
        while range.location < material.count {
            var matched = false
            for (re, tag) in tokenRegExprs {
                if let match = re.firstMatch(in: material, options: .anchored, range: range) {
                    // If matched, create token, push it to tokens array and update tokenize states
                    let text = (material as NSString).substring(with: match.range)
                    let token = Token(text: text, tag: tag, position: position, lineNum: lineNum)
                    
                    if ReservedWords.contains(token.text) {
                        token.tag = .Reserved
                    }
                    if token.tag != .None {
                        tokens.append(token)
                    }
                    
                    let newLineNum = token.text.count("\n")
                    if newLineNum > 0 {
                        lineNum += newLineNum
                        position = 0
                        errorNumberInCurrentLine = 0
                    }
                    let lastLine = token.text.components(separatedBy: CharacterSet(charactersIn: "\n")).last!
                    position += lastLine.count + 3 * lastLine.count("\t")
                    lastLength = match.range.length
                    range.location += lastLength
                    range.length -= lastLength
                    
                    matched = true
                    break
                }
            }
            
            // Throw error when material does not match any of the regexs
            if !matched {
                let error = MJCError(code: InvalidCharacterError, info: "Invalid Character", position: position + errorNumberInCurrentLine, lineNum: lineNum)
                error.print()
                material.remove(at: String.Index.init(encodedOffset: range.location))
                range.location -= lastLength // recover to last matched starting point
                range.length += lastLength
                range.length -= 1 // a character has been removed
                lastLength = 0 // clear last length to prevent multiple back-off
                errorNumberInCurrentLine += 1
                success = false
            }
        }
        return success ? tokens : nil
    }
    
}

/* String extension to count occurrences of a substring */
extension String {
    func count(_ substr: String) -> Int {
        var ctr = 0
        var crtRange = startIndex ..< endIndex
        while let nextRange = range(of: substr, options: CompareOptions(rawValue: 0), range: crtRange, locale: nil) {
            ctr += 1
            crtRange = nextRange.upperBound ..< endIndex
        }
        return ctr
    }
}
