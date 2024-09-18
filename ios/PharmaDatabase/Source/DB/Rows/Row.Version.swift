//
//  Version.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 31.03.21.
//

import GRDB

internal extension PharmaDatabase.Row {

    struct Version: Codable {
        let id, major, minor, patch: Int

        // sourcery: fixture
        internal init(id: Int, major: Int, minor: Int, patch: Int) {
            self.id = id
            self.major = major
            self.minor = minor
            self.patch = patch
        }
    }
}

extension PharmaDatabase.Row.Version: FetchableRecord, ValidatableTableRecord {

    enum Columns: String, RawRepresentable, CaseIterable, ColumnExpression {
        case id, major, minor, patch
    }

    static var databaseTableName: String { "version" }
}
