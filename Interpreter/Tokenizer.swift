//
//  Tokenizer.swift
//  Interpreter
//
//  Created by Nycshisan on 2016/12/17.
//  Copyright © 2016年 Nycshisan. All rights reserved.
//

import Foundation

let LEX_ERROR = 1

/* Tokenizer Inputs */
let ReservedWords = ["print", "if", "else", "while", "not", "and", "or"]

var ReservedRegExpPattern: String {
    return ReservedWords.map({ word in "(\(word))" }).joined(separator: "|")
}

let TokenExpressions: [(pattern: String, tag: TokenTag)] = [
    ("//.*$", .None),
    ("\\s+", .None),
    ("[=+-/*><!&|]+", .Reserved), // Operators
    ("[(){}]", .Reserved), // Delimiters
    (ReservedRegExpPattern, .Reserved),
    ("[0-9]+", .Int),
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
                debugPrint(error)
            }
        }
    }
    
    func tokenize(material: String) throws -> [Token] {
        var tokens: [Token] = []
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
                let userInfo = ["location": range.location]
                throw NSError(domain: "TokenizerErrorDomain", code: LEX_ERROR, userInfo: userInfo)
            } else {
                if token.tag != .None {
                    tokens.append(token)
                }
                range.location += match!.range.length
                range.length -= match!.range.length
            }
        }
        return tokens
    }
    
}
