//
//  Autolink.swift
//  Interfaces
//
//  Created by Aamir Suhial Mir on 25.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct Autolink: Codable {
    public let phrase: String
    public let xid: LearningCardIdentifier
    public let score: Int
    public let anchor: LearningCardAnchorIdentifier

    // sourcery: fixture:
    public init(phrase: String, xid: LearningCardIdentifier, score: Int, anchor: LearningCardAnchorIdentifier) {
        self.phrase = phrase
        self.xid = xid
        self.score = score
        self.anchor = anchor
    }
}
