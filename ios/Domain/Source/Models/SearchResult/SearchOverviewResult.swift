//
//  SearchOverviewResult.swift
//  Interfaces
//
//  Created by Mohamed Abdul Hameed on 25.08.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

public struct SearchOverviewResult {
    public let phrasionary: PhrasionaryItem?
    public let articleItems: [ArticleSearchItem]
    public let articleItemsTotalCount: Int
    public let articlePageInfo: PageInfo?

    public let pharmaInfo: PharmaInfo?
    public let guidelineItems: [GuidelineSearchItem]
    public let guidelineItemsTotalCount: Int
    public let guidelinePageInfo: PageInfo?

    public let mediaItems: [MediaSearchItem]
    public let mediaFiltersResult: MediaFiltersResult
    public let mediaItemsTotalCount: Int
    public let mediaPageInfo: PageInfo?

    public let correctedSearchTerm: String?

    public let overviewSectionOrder: [SearchResultContentType]?

    public let targetScope: SearchResultsTargetScope?

    // sourcery: fixture:
    public init(
        phrasionary: PhrasionaryItem?,
        articleItems: [ArticleSearchItem],
        articleItemsTotalCount: Int,
        articlePageInfo: PageInfo?,
        pharmaInfo: PharmaInfo?,
        guidelineItems: [GuidelineSearchItem],
        guidelineItemsTotalCount: Int,
        guidelinePageInfo: PageInfo?,
        mediaItems: [MediaSearchItem],
        mediaFiltersResult: MediaFiltersResult,
        mediaItemsTotalCount: Int,
        mediaPageInfo: PageInfo?,
        correctedSearchTerm: String?,
        overviewSectionOrder: [SearchResultContentType]?,
        targetScope: SearchResultsTargetScope?
    ) {
        self.phrasionary = phrasionary
        self.articleItems = articleItems
        self.articleItemsTotalCount = articleItemsTotalCount
        self.articlePageInfo = articlePageInfo
        self.pharmaInfo = pharmaInfo
        self.guidelineItems = guidelineItems
        self.guidelineItemsTotalCount = guidelineItemsTotalCount
        self.guidelinePageInfo = guidelinePageInfo
        self.mediaItems = mediaItems
        self.mediaFiltersResult = mediaFiltersResult
        self.mediaItemsTotalCount = mediaItemsTotalCount
        self.mediaPageInfo = mediaPageInfo
        self.correctedSearchTerm = correctedSearchTerm
        self.overviewSectionOrder = overviewSectionOrder
        self.targetScope = targetScope
    }
}

public extension SearchOverviewResult {
    // sourcery: fixture:
    enum PharmaInfo {
        case pharmaCard(pharmaItems: [PharmaSearchItem], pharmaItemsTotalCount: Int, pageInfo: PageInfo?)
        case monograph(monographItems: [MonographSearchItem], monographItemsTotalCount: Int, pageInfo: PageInfo?)
    }
}

public extension SearchOverviewResult {
    struct PageInfo {
        public let endCursor: String?
        public let hasNextPage: Bool

        // sourcery: fixture:
        public init(endCursor: String?, hasNextPage: Bool) {
            self.endCursor = endCursor
            self.hasNextPage = hasNextPage
        }
    }
}

public enum SearchResultContentType {
    case phrasionary
    case article
    case pharmaSubstance
    case pharmaMonograph
    case media
    case guideline
    case libraryList
    case course
}

// sourcery: fixture:
public enum SearchResultsTargetScope {
    case overview
    case article
    case media
    case pharma
    case guideline
}
