//
//  Domain.Agent+Init.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 23.04.21.
//

import Foundation
import GRDB
import Domain

extension Domain.Substance {

    init(row: PharmaDatabase.Row.AmbossSubstance, drugs: [PharmaDatabase.Row.Drug], pocketCard: Domain.PocketCard?) throws {

        let id = SubstanceIdentifier(value: row.id)

        guard let name = row.name else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "amboss_substance", column: "name", id: id.value)
        }

        guard let basedOn = row.based_on_drug_id else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "amboss_substance", column: "based_on_drug_id", id: id.value)
        }

        let drugReferences = try drugs.map { try DrugReference(row: $0) }

        self.init(id: id, name: name, drugReferences: drugReferences, pocketCard: pocketCard, basedOn: .init(value: basedOn))
    }
}
