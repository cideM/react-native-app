//
//  Domain.Drug.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 07.05.21.
//

import Foundation
import GRDB
import Domain

extension Domain.Drug {

    init(row: PharmaDatabase.Row.Drug, sections: [PharmaDatabase.Row.Section], packages: [PharmaDatabase.Row.Package]) throws {

        let eid = DrugIdentifier(value: row.id)

        guard let ambossSubstanceId = row.amboss_substance_id else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "drug", column: "amboss_substance_id", id: row.id)
        }
        let substanceID = SubstanceIdentifier(value: ambossSubstanceId)

        guard let name = row.name else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "drug", column: "name", id: row.id)
        }

        guard let atcLabel = row.atc_label else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "drug", column: "atc_label", id: row.id)
        }

        guard let publishedAtTs = row.published_at_ts else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "drug", column: "published_at_ts", id: row.id)
        }

        guard
            let dosageFormsJSON = row.dosage_forms,
            let dosageForms = try JSONDecoder().stringArray(from: dosageFormsJSON)
        else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "drug", column: "dosage_forms", id: row.id)
        }

        let publishedAt = ISO8601DateFormatter.string(from: publishedAtTs)

        let prescriptions = try [Prescription].with(row: row)
        let pharmaSections = try sections.enumerated().map { position, row in try PharmaSection(row: row, position: position) }

        let pricesAndPackages = try packages.map {
            try PriceAndPackage(row: $0)
        }

        self.init(eid: eid,
                  substanceID: substanceID,
                  name: name,
                  atcLabel: atcLabel,
                  vendor: row.vendor,
                  prescriptions: prescriptions,
                  dosageForm: dosageForms,
                  sections: pharmaSections,
                  patientPackageInsertUrl: row.patient_package_insert_url,
                  prescribingInformationUrl: row.prescribing_information_url,
                  publishedAt: publishedAt,
                  pricesAndPackages: pricesAndPackages)
    }
}
