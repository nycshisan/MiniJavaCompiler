//
//  Tokenizer.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

import Foundation

let TOKENIZE_ERROR = 1

/* Tokenizer Inputs */
let ReservedWords = ["print", "if", "else", "while", "not", "and", "or"]

var ReservedRegExpPattern: String {
    return ReservedWords.map({ word in "(\(word))" }).joined(separator: "|")
}

let TokenExpressions: [(pattern: String, tag: TokenTag)] = [
    ("//.*$", .None),
    ("\\s+", .None),
    ("[-+/*=><!&|%^]+", .Reserved), // Operators
    ("[(){}]", .Reserved), // Delimiters
    (ReservedRegExpPattern, .Reserved),
    ("-?[0-9]+", .Int),
    ("[A-Za-z][A-Za-z0-9]*", .Id)
]

/* Token type */
struct Token {
    var text: String
    var tag: TokenTag
}

enum TokenTag {
    case Reserved
    case Separator
    case Int
    case Id
    case None
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
        
        let characters = material.characters
        var range = NSMakeRange(0, characters.count)
        while range.location < characters.count {
            var token = Token(text: "", tag: .None)
            var match: NSTextCheckingResult? = nil
            for (re, tag) in tokenRegExprs {
                match = re.firstMatch(in: material, options: .anchored, range: range)
                if match != nil {
                    token.text = (material as NSString).substring(with: match!.range)
                    token.tag = tag
                    break
                }
            }
            if match == nil {
                range.length = 1
                let userInfo: [String : Any] = ["range": range, "lineNum": lineNum]
                throw NSError(domain: "TokenizerErrorDomain", code: TOKENIZE_ERROR, userInfo: userInfo)
            } else {
                if token.tag != .None {
                    tokens.append(token)
                }
                lineNum += token.text.count("\n")
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
            let range = info["range"] as! NSRange
            print("Invalid character at line \(lineNum + 1):")
            print("\"\(material.components(separatedBy: "\n")[lineNum])\"")
            print("At Character:", (material as NSString).substring(with: range))
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
