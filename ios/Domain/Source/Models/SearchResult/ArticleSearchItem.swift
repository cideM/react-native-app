//
//  ArticleSearchItem.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 02.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

public struct ArticleSearchItem: Equatable {
    public let title: String
    public let body: String?
    public let deepLink: LearningCardDeeplink
    public let children: [ArticleSearchItem]
    public let resultUUID: String
    public let targetUUID: String

    // sourcery: fixture:
    public init(title: String,
                body: String?,
                deepLink: LearningCardDeeplink,
                children: [ArticleSearchItem],
                resultUUID: String,
                targetUUID: String) {
        self.title = title
        self.body = body
        self.deepLink = deepLink
        self.children = children
        self.resultUUID = resultUUID
        self.targetUUID = targetUUID
    }
}
