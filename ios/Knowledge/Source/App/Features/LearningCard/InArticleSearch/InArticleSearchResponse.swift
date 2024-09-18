//
//  InArticleSearchResult.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 21.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

struct InArticleSearchResponse: Codable {
    let identifier: InArticleSearchResponseIdentifier
    let results: [InArticleResultIndentifier]

    private enum CodingKeys: String, CodingKey {
        case identifier = "QueryId"
        case results = "r"
    }

    // sourcery: fixture:
    init(identifier: InArticleSearchResponseIdentifier, results: [InArticleResultIndentifier]) {
        self.identifier = identifier
        self.results = results
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let identifierString = try container.decode(String.self, forKey: .identifier)
        identifier = InArticleSearchResponseIdentifier(id: identifierString)

        let resultsArray = try container.decode([String].self, forKey: .results)
        results = resultsArray.map(InArticleResultIndentifier.init)
    }
}

struct InArticleSearchResponseIdentifier: Equatable, Codable {
    let id: String

    // sourcery: fixture:
    init(id: String) {
        self.id = id
    }
}

struct InArticleResultIndentifier: Equatable, Codable {
    let id: String

    // sourcery: fixture:
    init(id: String) {
        self.id = id
    }
}
