//
//  Error.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 31.03.21.
//

import Foundation
import GRDB
import Domain

public extension PharmaDatabase {

    enum SchemaValidationError: Error {
        case schemaMajorVersionMismatch(version: Domain.Version, required: Int)
        case schemaMinorVersionMismatch(version: Domain.Version, required: Int)
        case tableMissing(table: String)
        case columnMissing(table: String, column: String)
    }

    enum FetchError: Error {
        case rowMissing(table: String)
        case unexpectedNilValue(table: String, column: String, id: String? = nil)
        case decodingError(table: String, column: String, id: String, error: Swift.Error)
        case missingJSONKey(table: String, column: String, id: String, missingKey: String)
        case unexpectedJSONValue(table: String, column: String, id: String, jsonKey: String, unexpectedValue: String)
        case unexpectedValue(table: String, column: String, id: String, value: String)
        case inflate
    }
}
