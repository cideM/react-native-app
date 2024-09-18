//
//  AmossSubstanceLink.swift
//  Domain
//
//  Created by Manaf Alabd Alrahim on 23.06.23.
//  Copyright © 2023 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct AmbossSubstanceLink {
    public let id: String
    public let name: String?
    public let deeplink: Deeplink?

    // sourcery: fixture:
    public enum Deeplink {
        case pharmaCard(PharmaCardDeeplink)
        case monograph(MonographDeeplink)
    }

    // sourcery: fixture:
    public init(id: String, name: String?, deeplink: Deeplink?) {
        self.id = id
        self.name = name
        self.deeplink = deeplink
    }
}
