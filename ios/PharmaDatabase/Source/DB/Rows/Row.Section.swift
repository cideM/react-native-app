//
//  Row.Section.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 23.04.21.
//

import GRDB

internal extension PharmaDatabase.Row {

    struct Section: Codable, Hashable {

        let id: Int
        let title: String?
        let content: Data?

        // sourcery: fixture:
        internal init(id: Int, title: String? = nil, content: Data? = nil) {
            self.id = id
            self.title = title
            self.content = content
        }
    }
}

extension PharmaDatabase.Row.Section: FetchableRecord, ValidatableTableRecord {

    enum Columns: String, RawRepresentable, CaseIterable, ColumnExpression {
        case id
        case title
        case content
    }

    static var databaseTableName: String { "section" }
}
