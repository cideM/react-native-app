//
//  PhrasionaryItem.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 31.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

public struct PhrasionaryItem {
    public let title: String
    public let body: String?
    public let synonyms: [String]
    public let etymology: String?
    public let targets: [SearchResultItem]
    public let resultUUID: String

    // sourcery: fixture:
    public init(title: String,
                body: String?,
                synonyms: [String],
                etymology: String?,
                targets: [SearchResultItem],
                resultUUID: String) {
        self.title = title
        self.body = body
        self.synonyms = synonyms
        self.etymology = etymology
        self.targets = targets
        self.resultUUID = resultUUID
    }
}
