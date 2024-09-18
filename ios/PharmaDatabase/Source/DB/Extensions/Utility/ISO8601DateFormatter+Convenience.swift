//
//  ISODateFormatter+Convenience.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 07.05.21.
//

import Foundation

// Creating date formatters is very expensive
// Hence this once, which is needed in exactly this form
// for each new ambossSubstance and new drug instance is stored here and reused
private let isoDateFormatter = ISO8601DateFormatter()

extension ISO8601DateFormatter {

    static func string(from timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return isoDateFormatter.string(from: date)
    }
}
