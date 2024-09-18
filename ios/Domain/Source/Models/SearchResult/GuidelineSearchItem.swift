//
//  GuidelineSearchItem.swift
//  Interfaces
//
//  Created by Merve Kavaklioglu on 20.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

public struct GuidelineSearchItem: Equatable {
    public let tags: [String]?
    public let title: String
    public let details: [String]?
    public let externalURL: String?
    public let resultUUID: String
    public let targetUUID: String

    // sourcery: fixture:
    public init(tags: [String]?,
                title: String,
                details: [String]?,
                externalURL: String?,
                resultUUID: String,
                targetUUID: String) {
        self.tags = tags ?? []
        self.title = title
        self.details = details ?? []
        self.externalURL = externalURL
        self.resultUUID = resultUUID
        self.targetUUID = targetUUID
    }
}
