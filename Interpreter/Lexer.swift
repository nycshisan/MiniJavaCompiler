//
//  Lexer.swift
//  Interpreter
//
//  Created by 陈十三 on 2016/12/17.
//  Copyright © 2016年 陈十三. All rights reserved.
//

import Foundation

let LEX_ERROR = 1

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

/* Lexer Class */
class Lexer {
    
    static let ReservedWords = ["print", "if", "else", "while"]
    
    static var ReservedRegExpPattern: String {
        return Lexer.ReservedWords.map({ word in "(\(word))" }).joined(separator: "|")
    }
    
    static let TokenExpressions: [(pattern: String, tag: TokenTag)] = [
        ("//.*$", .None),
        ("\\s+", .None),
        ("[=+-/\\*(){}]+", .Reserved),
        (Lexer.ReservedRegExpPattern, .Reserved),
        ("[0-9]+", .Int),
        ("[A-Za-z][A-Za-z0-9]*", .Id)
    ]
    
    var tokenRegExprs: [(re: NSRegularExpression, tag: TokenTag)] = []
    
    var material: String
    var material_ns: NSString
    var characters: String.CharacterView
    
    var tokens: [Token]
    
    init(material: String) {
        self.material = material
        self.material_ns = material as NSString
        self.characters = material.characters
        self.tokens = []
        // Prepare Regular Expressions
        for expr in Lexer.TokenExpressions {
            do {
                let re = try NSRegularExpression(pattern: expr.pattern, options: NSRegularExpression.Options.anchorsMatchLines)
                tokenRegExprs.append((re, expr.tag))
            } catch {
                debugPrint(error)
            }
        }
    }
    
    func lex() throws {
        var range = NSMakeRange(0, characters.count)
        while range.location < characters.count {
            var token = Token(text: "", tag: .None)
            var match: NSTextCheckingResult? = nil
            for (re, tag) in tokenRegExprs {
                match = re.firstMatch(in: material, options: .anchored, range: range)
                if match != nil {
                    token.text = material_ns.substring(with: match!.range)
                    token.tag = tag
                    break
                }
            }
            if match == nil {
                // TODO: Finish practical error handling
                range.length = 20
                NSLog("Lex Error at %d: %@", range.location, material_ns.substring(with: range))
                throw NSError(domain: "LexerErrorDomain", code: LEX_ERROR, userInfo: nil)
            } else {
                if token.tag != .None {
                    tokens.append(token)
                }
                range.location += match!.range.length
                range.length -= match!.range.length
            }
        }
    }
    
}
