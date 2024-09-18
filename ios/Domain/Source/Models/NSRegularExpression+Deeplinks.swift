//
//  NSRegularExpression+Deeplinks.swift
//  Interfaces
//
//  Created by Silvio Bulla on 01.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

extension NSRegularExpression {
    func getMatchingGroupValues(string: String) -> [String] {
        guard let match = firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) else {
            return []
        }

        var stringValues: [String] = []

        for index in 0..<match.numberOfRanges {
            let range = match.range(at: index)
            stringValues.append((string as NSString).substring(with: range))
        }

        return stringValues
    }

    static func regexp(pattern: String, options: NSRegularExpression.Options = []) throws -> NSRegularExpression {
        try NSRegularExpression(pattern: pattern, options: options)
    }

    static func getFirstMatchingGroupValues(string: String, regexps: [NSRegularExpression]) -> [String] {
        for regex in regexps {
            let match = regex.getMatchingGroupValues(string: string)

            if !match.isEmpty {
                return match
            }
        }

        return []
    }
}
