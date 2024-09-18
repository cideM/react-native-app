//
//  Domain.DrugReference+Init.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 23.04.21.
//

import Foundation
import GRDB
import Domain

extension Domain.DrugReference {

    init(row: PharmaDatabase.Row.Drug) throws {
        guard let name = row.name else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "drug", column: "name", id: row.id)
        }

        guard let atcLabel = row.atc_label else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "drug", column: "atc_label", id: row.id)
        }

        let applicationForms = try [ApplicationForm].with(row: row)
        let prescriptions = try [Prescription].with(row: row)

        self.init(id: DrugIdentifier(value: row.id), name: name, vendor: row.vendor, atcLabel: atcLabel, prescriptions: prescriptions, applicationForms: applicationForms, pricesAndPackages: [])
    }
}
