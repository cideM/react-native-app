//
//  Version.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 03.09.24.
//

import GRDB

internal extension PharmaDatabase.Row {

    struct PocketCardSection: Codable {
        let id, pocket_card_group_id, title, content: String // swiftlint:disable:this identifier_name
        let position: Int?

        // swiftlint:disable:next identifier_name
        // sourcery: fixture
        internal init(id: String, pocket_card_group_id: String, position: Int?, title: String, content: String) {
            self.id = id
            self.pocket_card_group_id = pocket_card_group_id
            self.position = position
            self.title = title
            self.content = content
        }
    }
}

extension PharmaDatabase.Row.PocketCardSection: FetchableRecord, ValidatableTableRecord {

    enum Columns: String, RawRepresentable, CaseIterable, ColumnExpression {
        case id, pocket_card_group_id, position, title, content
    }

    static var databaseTableName: String { "pocket_card_section" }
}
