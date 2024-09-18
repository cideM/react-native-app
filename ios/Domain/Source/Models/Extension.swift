//
//  Extension.swift
//  Knowledge
//
//  Created by Mohamed Abdul-Hameed on 10/1/19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Foundation

public struct Extension: Codable, Equatable {

    public let learningCard: LearningCardIdentifier
    public let section: LearningCardSectionIdentifier
    public let updatedAt: Date

    /// Previous updated at is the time when this extension was update on the server.
    /// It should only ever change if this extension is fetched from the server.
    public let previousUpdatedAt: Date?
    public let note: String

    public var unformattedNote: String {
        note.replacingOccurrences(of: "<\\/?(h1|h2|h3|h4|h5|h6|p|br|u|em|strong|ul|ol|li|b|i) ?\\/?>", with: "", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "&nbsp;", with: " ")
    }

    // sourcery: fixture:
    public init(learningCard: LearningCardIdentifier, section: LearningCardSectionIdentifier, updatedAt: Date, previousUpdatedAt: Date?, note: String) {
        self.learningCard = learningCard
        self.section = section
        self.updatedAt = updatedAt
        self.previousUpdatedAt = previousUpdatedAt
        self.note = note
    }
}
