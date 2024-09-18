//
//  Token.swift
//  Interfaces
//
//  Created by Cornelius Horstmann on 05.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

enum Token {
    case string(String)
    case oneOf([String]) // -> At least one of the strings inside the array needs to match
    case any
    case xid(length: Int? = nil) // -> nil length means: any length is accepted
}

extension Token: ExpressibleByStringLiteral {
    typealias StringLiteralType = String

    init(stringLiteral value: Self.StringLiteralType) {
        self = .string(value)
    }
}

func ~= (pattern: Token, predicate: String) -> Bool {
    switch pattern {
    case .any:
        return true
    case .string(let string) where predicate == string:
        return true
    case .oneOf(let strings) where strings.contains(predicate):
        return true
    case .xid(let int) where int == nil:
        return true
    case .xid(let int) where predicate.count == int:
        return true
    default:
        return false
    }
}

func ~= (pattern: [Token], predicate: [String]) -> Bool {
    guard pattern.count <= predicate.count else { return false }
    return pattern.enumerated()
        .map { (token: $0.element, predicate: predicate[$0.offset] ) }
        .allSatisfy { $0.token ~= $0.predicate }
}
