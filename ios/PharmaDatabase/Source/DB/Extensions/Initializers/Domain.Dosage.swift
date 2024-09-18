//
//  Domain.Dosage.swift
//  PharmaDatabase
//
//  Created by Roberto Seidenberg on 11.10.22.
//

import Foundation
import GRDB
import Domain

extension Domain.Dosage {

    init(dosage: PharmaDatabase.Row.Dosage, ambossSubstance: PharmaDatabase.Row.AmbossSubstance?) throws {
        let dosageId = DosageIdentifier(value: dosage.id)

        var ambossSubstanceLink: AmbossSubstanceLink?

        if let ambossSubstanceId = dosage.as_link_as_id,
           let ambossSubstanceDrugId = dosage.as_link_drug_id {
            let pharmaDeeplink = PharmaCardDeeplink(substance: SubstanceIdentifier(value: ambossSubstanceId),
                                                    drug: DrugIdentifier(value: ambossSubstanceDrugId))
            ambossSubstanceLink = AmbossSubstanceLink(id: ambossSubstanceId,
                                                      name: ambossSubstance?.name,
                                                      deeplink: .pharmaCard(pharmaDeeplink)
            )
        }

        self.init(id: dosageId,
                  html: dosage.html,
                  ambossSubstanceLink: ambossSubstanceLink)
    }
}
