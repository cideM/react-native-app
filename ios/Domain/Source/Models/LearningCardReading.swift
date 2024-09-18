//
//  LearningCardReading.swift
//  Interfaces
//
//  Created by Silvio Bulla on 07.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct LearningCardReading: Codable, Equatable {

    public let identifier: UUID
    public let learningCard: LearningCardIdentifier
    public let openedAt: Date
    public var closedAt: Date?

    /// Elapsed time (in seconds) reading a learning card.
    public var timeSpent: Int {
        guard let closedAt = closedAt else { return 0 }
        return Int(closedAt.timeIntervalSince(openedAt).rounded(.up))
    }

    // sourcery: fixture:
    public init(learningCard: LearningCardIdentifier, openedAt: Date, closedAt: Date? = nil) {
        self.identifier = UUID()
        self.learningCard = learningCard
        self.openedAt = openedAt
        self.closedAt = closedAt
    }

}
