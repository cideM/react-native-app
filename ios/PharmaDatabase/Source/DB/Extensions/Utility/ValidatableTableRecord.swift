//
//  PharmaDatabase+SanityChecks.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 01.04.21.
//

import Foundation
import GRDB

protocol ValidatableTableRecord: TableRecord {

    associatedtype Columns: CaseIterable, ColumnExpression
    static func validate(in database: Database) throws
}

extension ValidatableTableRecord {

    static func validate(in database: Database) throws {
        let columns = Columns.allCases.map { $0.name }
        try database.require(table: databaseTableName, columns: columns)
    }
}

// GRDB might run into a fatalError() when attempting to access tables and columns that do not exist
// This extension contains sanity checks that can be used to prevent accessing non existent structure
// Regrettably those checks need to fall back to raw SQL statements
// There is no way around it since the GRDB abstraction layer is crashing in case the abstraction is wrong
// Hence we need to go in here and check if the data matches the expectation using raw sql before
// actually handing it over to the upper (SQL "free") layer
extension Database {

    func require(table: String, columns: [String]? = nil) throws {

        // Check if the table exists ...
        let row = try GRDB.Row.fetchOne(self, sql: "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?", arguments: [table])
        guard let count = row?.count, count > 0 else {
            throw PharmaDatabase.SchemaValidationError.tableMissing(table: table)
        }

        // Check if the table has all the required columns ...
        if let columns = columns {
            var foundColumnNames = [String]()
            let rows = try GRDB.Row.fetchAll(self, sql: "PRAGMA table_info(\(table))") // <- SQL arguments not supported in PRAGMAs
            for row in  rows {
                for column in row where column.0 == "name" {
                    switch column.1.storage {
                    case .string(let value): foundColumnNames.append(value)
                    default: break
                    }
                }
            }

            for columnName in columns {
                if !foundColumnNames.contains(columnName) { throw PharmaDatabase.SchemaValidationError.columnMissing(table: table, column: columnName) }
            }
        }
    }
}
