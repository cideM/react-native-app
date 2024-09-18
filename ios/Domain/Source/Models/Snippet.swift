//
//  Snippet.swift
//  Interfaces
//
//  Created by Silvio Bulla on 11.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation

public typealias SnippetIdentifier = Identifier<Snippet, String>

public struct Snippet {
    public let identifier: SnippetIdentifier
    public let synonyms: [String]
    public let title: String?
    public let etymology: String?
    public let description: String?
    public let destinations: [SnippetDestination]

    // sourcery: fixture:
    public init(synonyms: [String], title: String?, etymology: String?, description: String?, destinations: [SnippetDestination], identifier: SnippetIdentifier) {
        self.synonyms = synonyms
        self.title = title
        self.etymology = etymology
        self.description = description
        self.destinations = destinations
        self.identifier = identifier
    }
}

extension Snippet: Codable {
    enum CodingKeys: String, CodingKey {
        case synonyms
        case title
        case etymology
        case description
        case destinations
        case identifier = "id"
    }
}
