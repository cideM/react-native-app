//
//  Row.Package.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 02.05.22.
//

import GRDB

internal extension PharmaDatabase.Row {

    struct Package: Codable, Hashable {
        let id: Int
        let drug_id: String? // swiftlint:disable:this identifier_name
        let position_ascending: Int? // swiftlint:disable:this identifier_name
        let position_mixed: Int? // swiftlint:disable:this identifier_name
        let package_size: String? // swiftlint:disable:this identifier_name
        let amount: String?
        let unit: String?
        let pharmacy_price: String? // swiftlint:disable:this identifier_name
        let recommended_price: String? // swiftlint:disable:this identifier_name
        let prescription: String?

        // sourcery: fixture
        // Please note: The fixture generated here will be invalid cause "package_size" requires specific values and sourcery can not know about these
        // swiftlint:disable:next identifier_name
        internal init(id: Int, drug_id: String?, position_ascending: Int?, position_mixed: Int?, package_size: String?, amount: String?, unit: String?, pharmacy_price: String?, recommended_price: String?, prescription: String?) {
            self.id = id
            self.drug_id = drug_id
            self.position_ascending = position_ascending
            self.position_mixed = position_mixed
            self.package_size = package_size
            self.amount = amount
            self.unit = unit
            self.pharmacy_price = pharmacy_price
            self.recommended_price = recommended_price
            self.prescription = prescription
        }
    }
}

extension PharmaDatabase.Row.Package: FetchableRecord, ValidatableTableRecord {

    enum Columns: String, RawRepresentable, CaseIterable, ColumnExpression {
        case id
        case drug_id // swiftlint:disable:this identifier_name
        case position_ascending // swiftlint:disable:this identifier_name
        case position_mixed // swiftlint:disable:this identifier_name
        case package_size // swiftlint:disable:this identifier_name
        case amount
        case unit
        case pharmacy_price // swiftlint:disable:this identifier_name
        case recommended_price // swiftlint:disable:this identifier_name
        case prescription
    }

    static var databaseTableName: String { "package" }
}
