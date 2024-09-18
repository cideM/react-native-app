//
//  SnippetDestination.swift
//  Interfaces
//
//  Created by Silvio Bulla on 11.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct SnippetDestination: Codable {
    public let articleEid: LearningCardIdentifier
    public let anchor: LearningCardAnchorIdentifier
    public let label: String?
    public let particleEid: LearningCardSectionIdentifier?

    public init(articleId: LearningCardIdentifier, particleEid: LearningCardSectionIdentifier?, anchor: LearningCardAnchorIdentifier, label: String?) {
        self.articleEid = articleId
        self.anchor = anchor
        self.label = label
        self.particleEid = particleEid
    }

    enum CodingKeys: String, CodingKey {
        case particleEid
        case anchor
        case label
        case articleEid = "lc_xid"
    }
}
