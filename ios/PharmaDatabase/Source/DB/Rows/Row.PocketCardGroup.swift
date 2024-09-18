//
//  Version.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 03.09.24.
//

import GRDB

internal extension PharmaDatabase.Row {

    struct PocketCardGroup: Codable {
        let id, pocket_card_id, title: String // swiftlint:disable:this identifier_name
        let position: Int?

        // swiftlint:disable:next identifier_name
        // sourcery: fixture
        internal init(id: String, pocket_card_id: String, position: Int?, title: String) {
            self.id = id
            self.pocket_card_id = pocket_card_id
            self.position = position
            self.title = title
        }
    }
}

extension PharmaDatabase.Row.PocketCardGroup: FetchableRecord, ValidatableTableRecord {

    enum Columns: String, RawRepresentable, CaseIterable, ColumnExpression {
        case id, pocket_card_id, position
    }

    static var databaseTableName: String { "pocket_card_group" }
}
