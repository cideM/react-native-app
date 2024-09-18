//
//  MonographSearchItem.swift
//  Interfaces
//
//  Created by Manaf Alabd Alrahim on 04.10.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct MonographSearchItem: Equatable {
    public let title: String
    public let details: [String]?
    public let deepLink: MonographDeeplink
    public let children: [MonographSearchItem]
    public let resultUUID: String
    public let targetUUID: String

    public var monographId: MonographIdentifier {
        deepLink.monograph
    }
    public var anchorId: MonographAnchorIdentifier? {
        deepLink.anchor
    }
    // sourcery: fixture:
    public init(id: MonographIdentifier,
                anchor: MonographAnchorIdentifier?,
                title: String,
                details: [String]?,
                children: [MonographSearchItem],
                resultUUID: String,
                targetUUID: String) {
        self.title = title
        self.details = details ?? []
        self.deepLink = MonographDeeplink(monograph: id, anchor: anchor)
        self.children = children
        self.resultUUID = resultUUID
        self.targetUUID = targetUUID
    }
}
