//
//  SearchPharmaResultItem.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 25.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

public struct PharmaSearchItem: Equatable {
    public let title: String
    public let details: [String]?
    public let deepLink: PharmaCardDeeplink
    public let resultUUID: String
    public let targetUUID: String

    public var substanceID: SubstanceIdentifier {
        deepLink.substance
    }
    public var drugid: DrugIdentifier? {
        deepLink.drug
    }

    // sourcery: fixture:
    public init(title: String,
                details: [String]?,
                substanceID: SubstanceIdentifier,
                drugid: DrugIdentifier?,
                resultUUID: String,
                targetUUID: String) {
        self.title = title
        self.details = details ?? []
        self.deepLink = PharmaCardDeeplink(substance: substanceID, drug: drugid, document: nil)
        self.resultUUID = resultUUID
        self.targetUUID = targetUUID
    }
}
