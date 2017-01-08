//
//  Tokenizer.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

import Foundation

let InvalidCharacterError = 1

/* Tokenizer Configs */
let ReservedWords = ["print", "if", "else", "while", "var"]

var ReservedRegExpPattern: String {
    return ReservedWords.map({ word in "(\(word))" }).joined(separator: "|")
}

let TokenExpressions: [(pattern: String, tag: TokenTag)] = [
    ("//.*$", .None), // Comments
    ("\\s+", .None), // Blanks
    ("[-+/*=><!&|%^~]+", .Reserved), // Operators
    ("[(){}:]", .Reserved), // Delimiters
    (ReservedRegExpPattern, .Reserved), // Reversed words
    ("-?[0-9]+", .Int), // Intergers
    ("[A-Za-z_][A-Za-z0-9_]*", .Id) // Identifies
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
    var text: String
    var tag: TokenTag
    var range: NSRange
    var lineNum: Int
    
    init(text: String = "", tag: TokenTag = .None, range: NSRange = NSRange(location: 0, length: 0), lineNum: Int = 0) {
        self.text = text
        self.tag = tag
        self.range = range
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
                debugPrint("Internal Error: ", error)
            }
        }
    }
    
    func tokenize(material: String) throws -> [Token] {
        var tokens: [Token] = []
        var lineNum = 0
        var position = 0
        
        let characters = material.characters
        var range = NSMakeRange(0, characters.count)
        while range.location < characters.count {
            let token = Token()
            var match: NSTextCheckingResult? = nil
            for (re, tag) in tokenRegExprs {
                match = re.firstMatch(in: material, options: .anchored, range: range)
                if match != nil {
                    // If matched, create token
                    token.text = (material as NSString).substring(with: match!.range)
                    token.tag = tag
                    token.range = range
                    token.lineNum = lineNum
                    break
                }
            }
            
            // Throw error or append tokens
            if match == nil {
                let userInfo: [String : Any] = ["position": position, "lineNum": lineNum]
                throw NSError(domain: "SSCompilerErrorDomain", code: InvalidCharacterError, userInfo: userInfo)
            } else {
                position += token.text.characters.count
                if token.tag != .None {
                    tokens.append(token)
                }
                let newLineNum = token.text.count("\n")
                if newLineNum > 0 {
                    lineNum += newLineNum
                    position = 0
                }
                range.location += match!.range.length
                range.length -= match!.range.length
            }
        }
        return tokens
    }
    
    func tokenizeCaughtError(material: String) -> [Token] {
        do { return try tokenize(material: material) } catch let error as NSError {
            let info = error.userInfo
            let lineNum = info["lineNum"] as! Int
            let line = material.components(separatedBy: "\n")[lineNum]
            let position = info["position"] as! Int
            print("Error: Invalid character at line \(lineNum + 1):")
            print("\(line)")
            print(String(repeating: " ", count: position) + "^")
            exit(Int32(error.code))
        }
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
