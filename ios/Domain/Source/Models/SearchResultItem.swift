//
//  SearchResultItem.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 02.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

public enum SearchResultItem: Equatable {
    case article(ArticleSearchItem)
    case pharma(PharmaSearchItem)
    case monograph(MonographSearchItem)
    case guideline(GuidelineSearchItem)
    case media(MediaSearchItem)
}

public extension SearchResultItem {
    var resultUUID: String {
        switch self {
        case .article(let articleSearchItem): return articleSearchItem.resultUUID
        case .pharma(let pharmaSearchItem): return pharmaSearchItem.resultUUID
        case .monograph(let monographSearchItem): return monographSearchItem.resultUUID
        case .guideline(let guidelineSearchItem): return guidelineSearchItem.resultUUID
        case .media(let mediaSearchItem): return mediaSearchItem.resultUUID
        }
    }
}

public extension SearchResultItem {
    var targetUUID: String {
        switch self {
        case .article(let articleSearchItem): return articleSearchItem.targetUUID
        case .pharma(let pharmaSearchItem): return pharmaSearchItem.targetUUID
        case .monograph(let monographSearchItem): return monographSearchItem.targetUUID
        case .guideline(let guidelineSearchItem): return guidelineSearchItem.targetUUID
        case .media(let mediaSearchItem): return mediaSearchItem.targetUUID
        }
    }
}
