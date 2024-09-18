//
//  SearchSuggestionResult.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 12.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain

struct SearchSuggestionResult {
    let resultType: SuggestionResultType
    let suggestions: [SearchSuggestionItem]

    // sourcery: fixture
    init(resultType: SuggestionResultType, suggestions: [SearchSuggestionItem]) {
        self.resultType = resultType
        self.suggestions = suggestions
    }
}

extension SearchSuggestionResult {
    // sourcery: fixture
    enum SuggestionResultType: Equatable {
        case offline
        case online
    }
}
