//
//  SearchResult.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 15.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Foundation

struct SearchResult {
    let resultType: SearchResultType

    private let searchOverviewResult: SearchOverviewResult

    var phrasionary: PhrasionaryItem? {
        searchOverviewResult.phrasionary
    }

    var searchArticleResultItems: [SearchResultItem]
    var searchArticleResultPageInfo: SearchOverviewResult.PageInfo?

    var searchPharmaResultItems: [SearchResultItem]
    var searchPharmaResultPageInfo: SearchOverviewResult.PageInfo?

    var searchGuidelineResultItems: [SearchResultItem]
    var searchGuidelineResultPageInfo: SearchOverviewResult.PageInfo?

    var searchMediaOverviewResultItems: [SearchResultItem]
    var searchMediaResultItems: [SearchResultItem]
    var searchMediaFiltersResult: MediaFiltersResult
    var searchMediaResultPageInfo: SearchOverviewResult.PageInfo?

    let correctedSearchTerm: String?
    let searchArticleResultsTotalCount: Int
    let searchPharmaResultsTotalCount: Int?
    let searchGuidelineResultsTotalCount: Int
    let searchMediaResultsTotalCount: Int

    let searchResultOverviewSectionOrder: [SearchResultContentType]?
    let searchResultsTargetScope: SearchResultsTargetScope?

    var duration: TimeInterval? {
        switch resultType {
        case .offline(let duration): return duration
        case .online(let duration): return duration
        }
    }

    // sourcery: fixture:
    init(resultType: SearchResultType, searchOverviewResult: SearchOverviewResult) {
        self.resultType = resultType
        self.searchOverviewResult = searchOverviewResult

        searchArticleResultItems = searchOverviewResult.articleItems.map { SearchResultItem.article($0) }
        searchArticleResultPageInfo = searchOverviewResult.articlePageInfo

        correctedSearchTerm = searchOverviewResult.correctedSearchTerm
        self.searchArticleResultsTotalCount = searchOverviewResult.articleItemsTotalCount

        switch searchOverviewResult.pharmaInfo {
        case .none:
            searchPharmaResultItems = []
            searchPharmaResultsTotalCount = nil
        case .pharmaCard(let pharmaItems, let pharmaItemsTotalCount, let pageInfo):
            searchPharmaResultItems = pharmaItems.map { SearchResultItem.pharma($0) }
            searchPharmaResultsTotalCount = pharmaItemsTotalCount
            searchPharmaResultPageInfo = pageInfo
        case .monograph(let monographItems, let monographItemsTotalCount, let pageInfo):
            searchPharmaResultItems = monographItems.map { SearchResultItem.monograph($0) }
            searchPharmaResultsTotalCount = monographItemsTotalCount
            searchPharmaResultPageInfo = pageInfo
        }

        searchGuidelineResultItems = searchOverviewResult.guidelineItems.map { SearchResultItem.guideline($0) }
        searchGuidelineResultPageInfo = searchOverviewResult.guidelinePageInfo

        self.searchGuidelineResultsTotalCount = searchOverviewResult.guidelineItemsTotalCount

        searchMediaOverviewResultItems = searchOverviewResult.mediaItems.map { SearchResultItem.media($0) }
        searchMediaResultItems = searchMediaOverviewResultItems
        searchMediaFiltersResult = searchOverviewResult.mediaFiltersResult
        searchMediaResultPageInfo = searchOverviewResult.mediaPageInfo

        self.searchMediaResultsTotalCount = searchOverviewResult.mediaItemsTotalCount
        self.searchResultOverviewSectionOrder = searchOverviewResult.overviewSectionOrder
        self.searchResultsTargetScope = searchOverviewResult.targetScope
    }

    mutating func appendArticleItems(_ items: [SearchResultItem], newPageInfo: SearchOverviewResult.PageInfo) {
        searchArticleResultItems += items
        searchArticleResultPageInfo = newPageInfo
    }

    mutating func appendGuidelineItems(_ items: [SearchResultItem], newPageInfo: SearchOverviewResult.PageInfo) {
        searchGuidelineResultItems += items
        searchGuidelineResultPageInfo = newPageInfo
    }

    mutating func appendPharmaItems(_ items: [SearchResultItem], newPageInfo: SearchOverviewResult.PageInfo) {
        searchPharmaResultItems += items
        searchPharmaResultPageInfo = newPageInfo
    }

    mutating func appendMediaItems(_ items: [SearchResultItem], newPageInfo: SearchOverviewResult.PageInfo) {
        searchMediaResultItems += items
        searchMediaResultPageInfo = newPageInfo
    }

    mutating func setMediaItems(_ items: [SearchResultItem], newPageInfo: SearchOverviewResult.PageInfo) {
        searchMediaResultItems = items
        searchMediaResultPageInfo = newPageInfo
    }

    mutating func setMediaFilters(result: MediaFiltersResult) {
        searchMediaFiltersResult = result
    }
}

extension SearchResult {
    // sourcery: fixture:
    enum SearchResultType: Equatable {
        case offline(duration: TimeInterval)
        case online(duration: TimeInterval)
    }
}
