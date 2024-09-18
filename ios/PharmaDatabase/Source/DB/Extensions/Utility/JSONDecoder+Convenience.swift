//
//  JSON+Convenience.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 20.04.21.
//

import Foundation

extension JSONDecoder {

    func stringArray(from json: String?) throws -> [String]? {
        guard let data = json?.data(using: .utf8) else { return nil }
        return try decode([String].self, from: data)
    }
}
