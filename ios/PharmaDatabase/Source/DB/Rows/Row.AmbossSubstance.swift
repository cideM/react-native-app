//
//  Row.AmbossSubstance.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 16.04.21.
//

import GRDB

internal extension PharmaDatabase.Row {

    struct AmbossSubstance: Codable, Hashable {

        let id: String
        let name: String?
        let based_on_drug_id: String? // swiftlint:disable:this identifier_name
        let prescriptions: String?
        let dosage_forms: String? // swiftlint:disable:this identifier_name
        let published_at_ts: Int64? // swiftlint:disable:this identifier_name
        let search_terms: String? // swiftlint:disable:this identifier_name
        let suggest_terms: String? // swiftlint:disable:this identifier_name
        let published: Bool

        // sourcery: fixture
        internal init(id: String, name: String?, based_on_drug_id: String?, prescriptions: String?, dosage_forms: String?, published_at_ts: Int64?, search_terms: String?, suggest_terms: String?, published: Bool) { // swiftlint:disable:this identifier_name
            self.id = id
            self.name = name
            self.based_on_drug_id = based_on_drug_id
            self.prescriptions = prescriptions
            self.dosage_forms = dosage_forms
            self.published_at_ts = published_at_ts
            self.search_terms = search_terms
            self.suggest_terms = suggest_terms
            self.published = published
        }
    }
}

extension PharmaDatabase.Row.AmbossSubstance: FetchableRecord, ValidatableTableRecord {

    // Colums 'search_terms' and 'suggest_terms' are being
    // queried using RAW sql syntax in PharmaDatabase+SuggestionsAndSearch.swift
    enum Columns: String, RawRepresentable, CaseIterable, ColumnExpression {
        case id
        case name
        case based_on_drug_id // swiftlint:disable:this identifier_name
        case prescriptions
        case dosage_forms // swiftlint:disable:this identifier_name
        case published_at_ts // swiftlint:disable:this identifier_name
        case search_terms // swiftlint:disable:this identifier_name
        case suggest_terms // swiftlint:disable:this identifier_name
        case published
    }

    static var databaseTableName: String { "amboss_substance" }
}
