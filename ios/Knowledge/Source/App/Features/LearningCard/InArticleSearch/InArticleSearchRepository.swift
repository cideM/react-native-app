//
//  InArticleSearchRepository.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 21.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

protocol InArticleSearchRepositoryType: AnyObject {
    var currentResponseIdentifier: InArticleSearchResponseIdentifier { get }
    var currentResultIndex: Int { get set }
    var resultCount: Int { get }
    var currentSearchResult: InArticleResultIndentifier { get }
    var countText: String { get }
}

final class InArticleSearchRepository: InArticleSearchRepositoryType {
    private let currentResponse: InArticleSearchResponse
    var currentResponseIdentifier: InArticleSearchResponseIdentifier {
        currentResponse.identifier
    }

    var currentResultIndex: Int {
        didSet {
            if currentResultIndex < 0 {
                currentResultIndex = currentResponse.results.count - 1
            } else {
                currentResultIndex = currentResultIndex % currentResponse.results.count
            }
        }
    }

    var currentSearchResult: InArticleResultIndentifier {
        currentResponse.results[currentResultIndex]
    }

    var resultCount: Int {
        currentResponse.results.count
    }

    var countText: String {
        if currentResponse.results.isEmpty {
            return "0/0"
        } else {
            return "\(currentResultIndex + 1)/\(currentResponse.results.count)"
        }
    }

    init?(currentResponse: InArticleSearchResponse) {
        guard !currentResponse.results.isEmpty else { return nil }

        self.currentResponse = currentResponse
        self.currentResultIndex = 0
    }

}
