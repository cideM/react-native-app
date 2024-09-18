//
//  SearchSuggestionItem.swift
//  Interfaces
//
//  Created by Merve Kavaklioglu on 04.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Foundation

// sourcery: fixture:
public enum SearchSuggestionItem: Equatable {
    case autocomplete(text: String?, value: String?, metadata: String?)
    case instantResult(InstantResult)

    public static func == (lhs: SearchSuggestionItem, rhs: SearchSuggestionItem) -> Bool {
        switch (lhs, rhs) {
        case (let .autocomplete(lhsText, lhsValue, _), let .autocomplete(rhsText, rhsValue, _)):
            return lhsText == rhsText && lhsValue == rhsValue
        case (let .instantResult(lhsInstantResult), .instantResult(let rhsInstantResult)):
            return lhsInstantResult == rhsInstantResult
        default: return false
        }
    }
}

public extension SearchSuggestionItem {

    // sourcery: fixture:
    enum InstantResult: Equatable {
        case article(text: String?, value: String?, deepLink: LearningCardDeeplink, metadata: String?)
        case pharmaCard(text: String?, value: String?, deepLink: PharmaCardDeeplink, metadata: String?)
        case monograph(text: String?, value: String?, deepLink: MonographDeeplink, metadata: String?)

        public static func == (lhs: SearchSuggestionItem.InstantResult, rhs: SearchSuggestionItem.InstantResult) -> Bool {
            switch (lhs, rhs) {
            case (let .article(lhsText, lhsValue, lhsDeepLink, _), let .article(rhsText, rhsValue, rhsDeepLink, _)):
                return lhsText == rhsText && lhsValue == rhsValue && lhsDeepLink == rhsDeepLink
            case (let .pharmaCard(lhsText, lhsValue, lhsDeepLink, _), let .pharmaCard(rhsText, rhsValue, rhsDeepLink, _)):
                return lhsText == rhsText && lhsValue == rhsValue && lhsDeepLink == rhsDeepLink
            case (let .monograph(lhsText, lhsValue, lhsDeepLink, _), let .monograph(rhsText, rhsValue, rhsDeepLink, _)):
                return lhsText == rhsText && lhsValue == rhsValue && lhsDeepLink == rhsDeepLink
            default: return false
            }
        }
    }
}
