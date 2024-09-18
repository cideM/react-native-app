//
//  PharmaDatabase+Dosage.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 11.10.22.
//

import Foundation
import GRDB
import Domain

public extension PharmaDatabase {

    func dosage(for identifier: DosageIdentifier) throws -> Domain.Dosage {

        let dosageRow: PharmaDatabase.Row.Dosage? = try queue.read { database in
            let predicate = Row.Dosage.Columns.id.like(identifier.value)
            return try Row.Dosage.filter(predicate).fetchOne(database)
        }

        guard let dosage = dosageRow else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "dosage", column: "id", id: identifier.value)
        }

        var ambossSubstance: PharmaDatabase.Row.AmbossSubstance?

        if let ambossSubstanceId = dosageRow?.as_link_as_id {
            ambossSubstance = try queue.read { database in
                let predicate = Row.AmbossSubstance.Columns.id.like(ambossSubstanceId)
                return try Row.AmbossSubstance.filter(predicate).fetchOne(database)
            }
        }

        return try Domain.Dosage(dosage: dosage, ambossSubstance: ambossSubstance)
    }
}
