//
//  PharmaSearchItem+Row.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 16.04.21.
//

import Foundation
import GRDB
import Domain

extension Domain.PharmaSearchItem {

    init(row: PharmaDatabase.Row.AmbossSubstance,
         basedOnDrug: PharmaDatabase.Row.Drug,
         highlight term: String = "") throws {
        guard let name = row.name else {
            throw PharmaDatabase.FetchError.unexpectedNilValue(table: "amboss_substance", column: "name")
        }

        let title = name.bolded(matching: term)

        var details = [String]()
        if let groupName = basedOnDrug.atc_label, !groupName.isEmpty {
            details = ["Gruppe: \(groupName.bolded(matching: term))"]
        }

        let substanceID = SubstanceIdentifier(value: row.id)
        let drugid = DrugIdentifier(value: basedOnDrug.id)

        self = Domain.PharmaSearchItem(title: title, details: details, substanceID: substanceID, drugid: drugid, resultUUID: "", targetUUID: "")
    }
}
