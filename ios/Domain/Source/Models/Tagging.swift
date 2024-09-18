//
//  Tag.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 10/2/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct Tagging: Codable, Equatable {
    public let type: Tag
    public let active: Bool
    public let updatedAt: Date
    public let learningCard: LearningCardIdentifier

    // sourcery: fixture:
    public init(type: Tag, active: Bool, updatedAt: Date, learningCard: LearningCardIdentifier) {
        self.type = type
        self.active = active
        self.updatedAt = updatedAt
        self.learningCard = learningCard
    }
}
