//
//  Version.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 03.09.24.
//

import GRDB

internal extension PharmaDatabase.Row {

    struct PocketCard: Codable {
        let id, amboss_substance_id: String // swiftlint:disable:this identifier_name

        // swiftlint:disable:next identifier_name
        // sourcery: fixture
        internal init(id: String, amboss_substance_id: String) {
            self.id = id
            self.amboss_substance_id = amboss_substance_id
        }
    }
}

extension PharmaDatabase.Row.PocketCard: FetchableRecord, ValidatableTableRecord {

    enum Columns: String, RawRepresentable, CaseIterable, ColumnExpression {
        case id, amboss_substance_id
    }

    static var databaseTableName: String { "pocket_card" }
}
