//
//  Row.DrugSection.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 07.05.21.
//

import GRDB

internal extension PharmaDatabase.Row {

    struct DrugSection: Codable, Hashable {

        let drug_id: String? // swiftlint:disable:this identifier_name
        let section_id: String? // swiftlint:disable:this identifier_name
        let position: Int?

        // sourcery: fixture
        internal init(drug_id: String?, section_id: String?, position: Int?) {  // swiftlint:disable:this identifier_name
            self.drug_id = drug_id
            self.section_id = section_id
            self.position = position
        }
    }
}

extension PharmaDatabase.Row.DrugSection: FetchableRecord, ValidatableTableRecord {

    enum Columns: String, RawRepresentable, CaseIterable, ColumnExpression {
        case drug_id // swiftlint:disable:this identifier_name
        case section_id // swiftlint:disable:this identifier_name
        case position
    }

    static var databaseTableName: String { "drug_section" }
}
