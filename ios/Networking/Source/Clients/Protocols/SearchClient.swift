//
//  SearchClient.swift
//  Networking
//
//  Created by Manaf Alabd Alrahim on 01.08.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain

/// @mockable
public protocol SearchClient: AnyObject {

    /// Returns the List of suggestions for given text
    /// - Parameters:
    ///   - text: The text for which user recieves the suggestions for.
    ///   - completion: A completion handler that will be called with result.
    func getSuggestions(for text: String, resultTypes: [SearchSuggestionResultType], timeout: TimeInterval, completion: @escaping Completion<[SearchSuggestionItem], NetworkError<EmptyAPIError>>)

    func overviewSearchDE(for text: String, limit: Int, timeout: TimeInterval, completion: @escaping Completion<SearchOverviewResult, NetworkError<EmptyAPIError>>)

    func overviewSearchUS(for text: String, limit: Int, timeout: TimeInterval, isMonographSearchAvailable: Bool, completion: @escaping Completion<SearchOverviewResult, NetworkError<EmptyAPIError>>)

    func getArticleResults(for text: String, limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<Page<ArticleSearchItem>?, NetworkError<EmptyAPIError>>)

    func getPharmaResults(for text: String, limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<Page<PharmaSearchItem>?, NetworkError<EmptyAPIError>>)

    func getMonographResults(for text: String, limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<Page<MonographSearchItem>?, NetworkError<EmptyAPIError>>)

    func getGuidelineResults(for text: String, limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<Page<GuidelineSearchItem>?, NetworkError<EmptyAPIError>>)

    func getMediaResults(for text: String, mediaFilters: [String], limit: Int, timeout: TimeInterval?, after: PaginationCursor?, completion: @escaping Completion<(Page<MediaSearchItem>?, MediaFiltersResult), NetworkError<EmptyAPIError>>)
}
