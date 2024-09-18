//
//  PharmaSearchViewItem.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 07.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain

struct PharmaSearchViewItem {
    let title: String
    let details: String?
    let substanceID: SubstanceIdentifier
    let drugId: DrugIdentifier?
    let targetUuid: String

    // sourcery: fixture:
    init(title: String,
         details: String?,
         substanceID: SubstanceIdentifier,
         drugId: DrugIdentifier?,
         targetUuid: String) {
        self.title = title
        self.details = details
        self.substanceID = substanceID
        self.drugId = drugId
        self.targetUuid = targetUuid
    }

    init(item: PharmaSearchItem) {
         let detailsString = (item.details ?? []).reduce(into: String()) { result, string in result.append("<br>\(string)") } // Adding a <br> here to make sure the HTML parser breaks the line between multple items ...
        self.init(title: item.title, details: detailsString, substanceID: item.substanceID, drugId: item.drugid, targetUuid: item.targetUUID)
     }
}
