//
//  SearchRepository.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 02.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Network
import Networking

/// @mockable
protocol SearchRepositoryType: AnyObject {
    func overviewSearch(for text: String, requestTimeout: TimeInterval, completion: @escaping (Result<SearchResult, SearchError>) -> Void)
    func fetchArticleSearchResultPage(for text: String, limit: Int, requestTimeout: TimeInterval?, after cursor: String?, completion: @escaping (Result<Page<ArticleSearchItem>?, SearchError>) -> Void)
    func fetchPharmaSearchResultPage(for text: String, limit: Int, requestTimeout: TimeInterval?, after cursor: String?, completion: @escaping (Result<Page<PharmaSearchItem>?, SearchError>) -> Void)
    func fetchPharmaSearchResultOffline(for text: String, completion: @escaping ([PharmaSearchItem]?) -> Void)
    func fetchMonographSearchResultPage(for text: String, limit: Int, requestTimeout: TimeInterval?, after cursor: String?, completion: @escaping (Result<Page<MonographSearchItem>?, SearchError>) -> Void)
    func fetchGuidelineSearchResultPage(for text: String, limit: Int, requestTimeout: TimeInterval?, after cursor: String?, completion: @escaping (Result<Page<GuidelineSearchItem>?, SearchError>) -> Void)
    func fetchMediaSearchResultPage(for text: String, mediaFilters: [String], limit: Int, requestTimeout: TimeInterval?, after cursor: String?, completion: @escaping (Result<(Page<MediaSearchItem>?, MediaFiltersResult), SearchError>) -> Void)
    func hasOfflinePharmaDB() -> Bool}

final class SearchRepository: SearchRepositoryType {

    @Inject private var tracer: Tracer
    /// Maximum number of search results returned
    private static let searchResultLimit = 20

    private let searchClient: SearchClient
    private let pharmaRepository: PharmaRepositoryType
    private let monographRepository: MonographRepositoryType
    private let appConfiguration: Configuration
    private let libraryRepository: LibraryRepositoryType
    private let pharmaService: PharmaDatabaseApplicationServiceType?
    private let trackingProvider: TrackingType
    private let snippetRepository: SnippetRepositoryType
    private let remoteConfigRepository: RemoteConfigRepositoryType

    init(searchClient: SearchClient = resolve(),
         libraryRepository: LibraryRepositoryType = resolve(),
         pharmaRepository: PharmaRepositoryType = resolve(),
         monographRepository: MonographRepositoryType = resolve(),
         appConfiguration: Configuration = AppConfiguration.shared,
         pharmaService: PharmaDatabaseApplicationServiceType? = resolve(),
         trackingProvider: TrackingType = resolve(),
         snippetRepository: SnippetRepositoryType = resolve(),
         remoteConfigRepository: RemoteConfigRepositoryType = resolve()) {
        self.searchClient = searchClient
        self.libraryRepository = libraryRepository
        self.pharmaRepository = pharmaRepository
        self.monographRepository = monographRepository
        self.appConfiguration = appConfiguration
        self.pharmaService = pharmaService
        self.trackingProvider = trackingProvider
        self.snippetRepository = snippetRepository
        self.remoteConfigRepository = remoteConfigRepository
    }
}

// MARK: - Library search

extension SearchRepository {

    func overviewSearch(for text: String, requestTimeout: TimeInterval, completion: @escaping (Result<SearchResult, SearchError>) -> Void) {
        let trace = tracer.startedTrace(name: .search, context: .search)
        trace.set(value: "overview", for: .searchScope)

        let startTime = Date()

        let completionHandler: (Result<SearchOverviewResult, NetworkError<EmptyAPIError>>) -> Void = { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let searchOverviewResult):
                trace.set(value: "true", for: .isOnlineResult)
                trace.stop()

                let duration = Date().timeIntervalSinceReferenceDate - startTime.timeIntervalSinceReferenceDate

                let searchResult = SearchResult(resultType: .online(duration: duration), searchOverviewResult: searchOverviewResult)
                completion(.success(searchResult))
            case .failure(let error):
                if case .noInternetConnection = error {
                    trace.set(value: "noInternetConnection", for: .onlineErrorCode)
                } else if case .requestTimedOut = error {
                    trace.set(value: "requestTimedOut", for: .onlineErrorCode)
                } else {
                    trace.set(value: "other", for: .onlineErrorCode)
                }

                self.overviewSearchOffline(for: text) { searchResult in
                    trace.set(value: "false", for: .isOnlineResult)
                    trace.stop()
                    completion(.success(searchResult))
                }
            }
        }

        switch appConfiguration.appVariant {
        case .wissen:
            searchClient.overviewSearchDE(for: text, limit: SearchRepository.searchResultLimit, timeout: requestTimeout, completion: completionHandler)
        case .knowledge:
            searchClient.overviewSearchUS(for: text, limit: SearchRepository.searchResultLimit, timeout: requestTimeout, isMonographSearchAvailable: remoteConfigRepository.areMonographsEnabled, completion: completionHandler)
        }
    }

    private func prepocessQueryForOffline(query: String) -> (targetScope: SearchResultsTargetScope?, query: String) {
        let array = query.split(separator: " ", omittingEmptySubsequences: true)
        var targetScope: SearchResultsTargetScope?
        var newQuery = ""
        for word in array {
            let lowerCasedWord = word.lowercased()
            if lowerCasedWord.hasPrefix("in:") {
                targetScope = SearchResultsTargetScope(searchPrefix: String(lowerCasedWord))
            } else {
                newQuery += " \(word)"
            }
        }

        return (targetScope, newQuery.trimmingCharacters(in: .whitespaces))
    }

    private func overviewSearchOffline(for query: String, completion: @escaping (SearchResult) -> Void) {
        let startDate = Date()

        let (targetScope, query) = prepocessQueryForOffline(query: query)

        let phrasionaryOfflineResultItem = phrasionarySearchOffline(for: query)
        let articleSearchOfflineResultItems = articleSearchOffline(for: query)
        let pharmaInfo: SearchOverviewResult.PharmaInfo
        switch appConfiguration.appVariant {
        case .wissen:
            let pharmaSearchOfflineResultItems = pharmaSearchOffline(for: query) ?? []
            pharmaInfo = .pharmaCard(pharmaItems: pharmaSearchOfflineResultItems, pharmaItemsTotalCount: pharmaSearchOfflineResultItems.count, pageInfo: nil)
        case .knowledge:
            // PHARMA-US-OFFLINE: when us offline is ready this is where offline data should be injected
            pharmaInfo = .monograph(monographItems: [], monographItemsTotalCount: 0, pageInfo: nil)
        }

        let overviewSearchOfflineResult = SearchOverviewResult(phrasionary: phrasionaryOfflineResultItem,
                                                               articleItems: articleSearchOfflineResultItems,
                                                               articleItemsTotalCount: articleSearchOfflineResultItems.count,
                                                               articlePageInfo: nil,
                                                               pharmaInfo: pharmaInfo,
                                                               guidelineItems: [],
                                                               guidelineItemsTotalCount: 0,
                                                               guidelinePageInfo: nil,
                                                               mediaItems: [],
                                                               mediaFiltersResult: MediaFiltersResult(filters: []),
                                                               mediaItemsTotalCount: 0,
                                                               mediaPageInfo: nil,
                                                               correctedSearchTerm: nil,
                                                               overviewSectionOrder: nil,
                                                               targetScope: targetScope)

        completion(SearchResult(resultType: .offline(duration: startDate.timeIntervalSinceNow), searchOverviewResult: overviewSearchOfflineResult))
    }

    private func phrasionarySearchOffline(for query: String) -> PhrasionaryItem? {
        guard let autolink = sortedAutolinks(for: query).first else { return nil }

        let learningCardDeepLink = LearningCardDeeplink(learningCard: autolink.xid, anchor: autolink.anchor, particle: nil, sourceAnchor: nil)
        let learningCard = try? libraryRepository.library.learningCardMetaItem(for: learningCardDeepLink.learningCard)

        if let title = learningCard?.title, let snippet = try? snippetRepository.snippet(for: learningCardDeepLink),
           let body = snippet.description {
            let target = SearchResultItem.article(ArticleSearchItem(title: title,
                                                                    body: body,
                                                                    deepLink: learningCardDeepLink,
                                                                    children: [],
                                                                    resultUUID: "",
                                                                    targetUUID: ""))
            return PhrasionaryItem(title: title, body: body, synonyms: snippet.synonyms, etymology: snippet.etymology, targets: [target], resultUUID: "")
        } else {
            return nil
        }
    }

    private func articleSearchOffline(for query: String) -> [ArticleSearchItem] {
        sortedAutolinks(for: query)
            .compactMap {
                let learningCardDeepLink = LearningCardDeeplink(learningCard: $0.xid, anchor: $0.anchor, particle: nil, sourceAnchor: nil)
                return searchResultItem(for: learningCardDeepLink, phrase: $0.phrase)
            }
    }

    private func sortedAutolinks(for query: String) -> [Autolink] {
        let words = query.components(separatedBy: " ")
        return libraryRepository.library.autolinks
            .filter { autolink in
                words.allSatisfy { autolink.phrase.lowercased().contains($0.lowercased()) }
            }
            .sorted { $0.score > $1.score }
    }

    private func pharmaSearchOffline(for query: String) -> [PharmaSearchItem]? {
        guard let database = self.pharmaService?.pharmaDatabase else { return nil }

        do {
            let items = try database.items(for: query)
            return items.map { PharmaSearchItem(title: $0.title, details: $0.details, substanceID: $0.substanceID, drugid: $0.drugid, resultUUID: "", targetUUID: "") }
        } catch {
            return nil
        }
    }

    func fetchArticleSearchResultPage(for text: String, limit: Int, requestTimeout: TimeInterval?, after cursor: String?, completion: @escaping (Result<Networking.Page<Domain.ArticleSearchItem>?, SearchError>) -> Void) {
        searchClient.getArticleResults(for: text, limit: limit, timeout: requestTimeout, after: cursor) { result in
            switch result {
            case .success(let page):
                completion(.success(page))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }

    func fetchPharmaSearchResultPage(for text: String, limit: Int, requestTimeout: TimeInterval?, after cursor: String?, completion: @escaping (Result<Page<PharmaSearchItem>?, SearchError>) -> Void) {
        searchClient.getPharmaResults(for: text, limit: limit, timeout: requestTimeout, after: cursor) { result in
            switch result {
            case .success(let page):
                completion(.success(page))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }

    func fetchPharmaSearchResultOffline(for text: String, completion: @escaping ([PharmaSearchItem]?) -> Void) {
        let completion = DispatchQueue.main.captureAsync(completion)

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let pharmaSearchOfflineResultItems = self?.pharmaSearchOffline(for: text)
            completion(pharmaSearchOfflineResultItems)
        }
    }

    func fetchMonographSearchResultPage(for text: String, limit: Int, requestTimeout: TimeInterval?, after cursor: String?, completion: @escaping (Result<Page<MonographSearchItem>?, SearchError>) -> Void) {
        searchClient.getMonographResults(for: text, limit: limit, timeout: requestTimeout, after: cursor) { result in
            switch result {
            case .success(let page):
                completion(.success(page))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }

    func fetchGuidelineSearchResultPage(for text: String, limit: Int, requestTimeout: TimeInterval?, after cursor: String?, completion: @escaping (Result<Page<GuidelineSearchItem>?, SearchError>) -> Void) {
        searchClient.getGuidelineResults(for: text, limit: limit, timeout: requestTimeout, after: cursor) { result in
            switch result {
            case .success(let page):
                completion(.success(page))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }

    func fetchMediaSearchResultPage(for text: String, mediaFilters: [String], limit: Int, requestTimeout: TimeInterval?, after cursor: String?, completion: @escaping (Result<(Page<MediaSearchItem>?, MediaFiltersResult), SearchError>) -> Void) {
        searchClient.getMediaResults(for: text, mediaFilters: mediaFilters, limit: limit, timeout: requestTimeout, after: cursor) { result in
            switch result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(.networkError(error)))
            }
        }
    }

    func hasOfflinePharmaDB() -> Bool {
        pharmaService?.pharmaDatabase != nil
    }
}

// MARK: - Library results

private extension SearchRepository {
    func searchResultItem(for deeplink: LearningCardDeeplink, phrase: String) -> ArticleSearchItem? {
        guard let learningCardMetadata = try? libraryRepository.library.learningCardMetaItem(for: deeplink.learningCard) else { return nil }
        return ArticleSearchItem(title: phrase, body: learningCardMetadata.title, deepLink: deeplink, children: [], resultUUID: "", targetUUID: "")
    }
}

extension SearchResultsTargetScope {
     init?(searchPrefix: String) {
        switch searchPrefix {
        case "in:arzneimittel",
            "in:drugs":
            self = .pharma
        case "in:flowcharts",
            "in:flussdiagramme",
            "in:calculators",
            "in:rechner":
            self = .media
        case "in:guidelines",
            "in:leitlinien":
            self = .guideline
        default:
            return nil
        }
    }
}
