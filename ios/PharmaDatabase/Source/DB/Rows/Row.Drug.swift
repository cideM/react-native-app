//
//  Row.Drug.swift
//  PharmaDatabase
//
//  Created by Silvio Bulla on 05.05.21.
//

import GRDB

internal extension PharmaDatabase.Row {

    struct Drug: Codable, Hashable {

        let id: String
        let name: String?
        let atc_label: String? // swiftlint:disable:this identifier_name
        let amboss_substance_id: String? // swiftlint:disable:this identifier_name
        let vendor: String?
        let application_forms: String? // swiftlint:disable:this identifier_name
        let prescriptions: String?
        let dosage_forms: String? // swiftlint:disable:this identifier_name
        let published_at_ts: Int64? // swiftlint:disable:this identifier_name
        let prescribing_information_url: String? // swiftlint:disable:this identifier_name
        let patient_package_insert_url: String? // swiftlint:disable:this identifier_name

        // sourcery: fixture
        internal init(id: String, name: String?, atc_label: String?, amboss_substance_id: String?, vendor: String?, application_forms: String?, prescriptions: String?, dosage_forms: String?, published_at_ts: Int64?, prescribing_information_url: String?, patient_package_insert_url: String?) { // swiftlint:disable:this identifier_name
            self.id = id
            self.name = name
            self.atc_label = atc_label
            self.amboss_substance_id = amboss_substance_id
            self.vendor = vendor
            self.application_forms = application_forms
            self.prescriptions = prescriptions
            self.dosage_forms = dosage_forms
            self.published_at_ts = published_at_ts
            self.prescribing_information_url = prescribing_information_url
            self.patient_package_insert_url = patient_package_insert_url
        }
    }
}

extension PharmaDatabase.Row.Drug: FetchableRecord, ValidatableTableRecord {

    enum Columns: String, RawRepresentable, CaseIterable, ColumnExpression {
        case id
        case name
        case atc_label // swiftlint:disable:this identifier_name
        case amboss_substance_id // swiftlint:disable:this identifier_name
        case vendor
        case application_forms // swiftlint:disable:this identifier_name
        case prescriptions
        case dosage_forms // swiftlint:disable:this identifier_name
        case published_at_ts // swiftlint:disable:this identifier_name
        case prescribing_information_url // swiftlint:disable:this identifier_name
        case patient_package_insert_url // swiftlint:disable:this identifier_name
    }

    static var databaseTableName: String { "drug" }
}
