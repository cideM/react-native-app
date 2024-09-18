//
//  Row.Dosage.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 11.10.22.
//

import GRDB

internal extension PharmaDatabase.Row {

    struct Dosage: Codable, Hashable {

        let id: String
        let html: String
        let as_link_as_id: String? // swiftlint:disable:this identifier_name
        let as_link_drug_id: String? // swiftlint:disable:this identifier_name

        // sourcery: fixture
        internal init(id: String, html: String, as_link_as_id: String?, as_link_drug_id: String?) { // swiftlint:disable:this identifier_name
            self.id = id
            self.html = html
            self.as_link_as_id = as_link_as_id
            self.as_link_drug_id = as_link_drug_id
        }
    }
}

extension PharmaDatabase.Row.Dosage: FetchableRecord, ValidatableTableRecord {

    enum Columns: String, RawRepresentable, CaseIterable, ColumnExpression {
        case id
        case html
        case as_link_as_id // swiftlint:disable:this identifier_name
        case as_link_drug_id // swiftlint:disable:this identifier_name
    }

    static var databaseTableName: String { "dosage" }
}
