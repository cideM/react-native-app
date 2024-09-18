//
//  SearchRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 13.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

import Foundation
import Domain
import Network
import Networking
@testable import PharmaDatabase

class SearchRepositoryTests: XCTestCase {

    var searchRepository: SearchRepositoryType!
    var searchClient: SearchClientMock!
    var appConfiguration: ConfigurationMock!
    var library: LibraryTypeMock!
    var pharmaRepository: PharmaRepositoryTypeMock!
    var snippetRepository: SnippetRepositoryTypeMock!
    var pharmaDatabase: PharmaDatabaseTypeMock!
    var pharmaService: PharmaDatabaseApplicationServiceTypeMock!

    override func setUp() {
        searchClient = SearchClientMock()
        appConfiguration = ConfigurationMock()
        pharmaRepository = PharmaRepositoryTypeMock()
        snippetRepository = SnippetRepositoryTypeMock()
        library = LibraryTypeMock()
        pharmaDatabase = PharmaDatabaseTypeMock()
        pharmaService = PharmaDatabaseApplicationServiceTypeMock(pharmaDatabase: pharmaDatabase, state: .idle(error: nil, availableUpdate: nil, type: .automatic))

        let libraryRepository = LibraryRepositoryTypeMock()
        libraryRepository.library = library

        searchRepository = SearchRepository(searchClient: searchClient, libraryRepository: libraryRepository, pharmaRepository: pharmaRepository, monographRepository: MonographRepositoryTypeMock(), appConfiguration: appConfiguration, pharmaService: pharmaService, snippetRepository: snippetRepository, remoteConfigRepository: RemoteConfigRepositoryTypeMock())
    }

    // MARK: - Library search

    func testThatOverviewSearchDeIsCalledWhenConfigurationIsSetToWissen() {
        appConfiguration.appVariant = .wissen
        searchClient.overviewSearchDEHandler = { _, _, _, completion in
            completion(.success(.fixture()))
        }
        XCTAssertEqual(searchClient.overviewSearchDECallCount, 0)
        XCTAssertEqual(searchClient.overviewSearchUSCallCount, 0)

        let expectation = self.expectation(description: "overviewSearch completion was called")
        searchRepository.overviewSearch(for: .fixture(), requestTimeout: .fixture()) { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(searchClient.overviewSearchDECallCount, 1)
        XCTAssertEqual(searchClient.overviewSearchUSCallCount, 0)
    }

    func testThatOverviewSearchUsIsCalledWhenConfigurationIsSetToKnowledge() {
        appConfiguration.appVariant = .knowledge
        searchClient.overviewSearchUSHandler = {  _, _, _, _, completion in
            completion(.success(.fixture()))
        }

        XCTAssertEqual(searchClient.overviewSearchDECallCount, 0)
        XCTAssertEqual(searchClient.overviewSearchUSCallCount, 0)

        let expectation = self.expectation(description: "overviewSearch completion was called")
        searchRepository.overviewSearch(for: .fixture(), requestTimeout: .fixture()) { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(searchClient.overviewSearchDECallCount, 0)
        XCTAssertEqual(searchClient.overviewSearchUSCallCount, 1)
    }

    func testThatWhenOnlineSearchSucceedsTheRepositoryReturnsTheReturnedResultInItsCompletion() {
        let expectedSearchResult: SearchOverviewResult = .fixture()
        appConfiguration.appVariant = .wissen
        searchClient.overviewSearchDEHandler = { _, _, _, completion in
            completion(.success(expectedSearchResult))
        }

        let expectation = self.expectation(description: "searchRespository overviewSearch completion was called")
        searchRepository.overviewSearch(for: .fixture(), requestTimeout: .fixture()) { result in
            switch result {
            case .success(let searchResult):
                XCTAssertEqual(searchResult.searchArticleResultsTotalCount, expectedSearchResult.articleItemsTotalCount)
                for (index, item) in searchResult.searchArticleResultItems.enumerated() {
                    if case let .article(articleItem) = item {
                        XCTAssertEqual(articleItem, expectedSearchResult.articleItems[index])
                    } else {
                        XCTFail("Should only contain article items")
                    }
                }

                for (index, item) in searchResult.searchPharmaResultItems.enumerated() {
                    if case let .pharma(pharmaItem) = item, case let .pharmaCard(expectedPharmaResultItems, _, _) = expectedSearchResult.pharmaInfo {
                        XCTAssertEqual(pharmaItem, expectedPharmaResultItems[index])
                    } else if case let .monograph(monographItem) = item, case let .monograph(expectedMonographResultItems, _, _) = expectedSearchResult.pharmaInfo {
                        XCTAssertEqual(monographItem, expectedMonographResultItems[index])
                    } else {
                        XCTFail("Unexpected result")
                    }
                }

                XCTAssertEqual(searchResult.correctedSearchTerm, expectedSearchResult.correctedSearchTerm)

                expectation.fulfill()
            case .failure:
                XCTFail("Should succeed as the client returns success")
            }
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenOnlineSearchFailsTheRepositoryCallsForOfflinePhrasionarySearch() {
        appConfiguration.appVariant = .wissen
        searchClient.overviewSearchDEHandler = { _, _, _, completion in
            completion(.failure(.other(.fixture())))
        }
        let searchQuery = "spec_1_Somthing_To_Search"
        let autoLinks = [
            Autolink.fixture(phrase: searchQuery, xid: LearningCardIdentifier.fixture(value: "spec_1"), score: 0),
            Autolink.fixture(phrase: .fixture(), xid: .fixture(), score: .fixture())
        ]

        library.autolinks = autoLinks

        let expectedLearningCardMetaItem: LearningCardMetaItem = .fixture()
        library.learningCardMetaItemHandler = { _ in
            expectedLearningCardMetaItem
        }

        let expectedSnippet: Snippet = .fixture()
        snippetRepository.snippetHandler = { _ in
            expectedSnippet
        }

        let expectation = self.expectation(description: "searchRepository search is called with search result")
        searchRepository.overviewSearch(for: searchQuery, requestTimeout: .fixture()) { result in
            switch result {
            case .success(let searchResult):
                switch searchResult.resultType {
                case .offline: break
                case .online: XCTFail("Unexpected result type")
                }

                XCTAssertNotNil(searchResult.phrasionary)
                XCTAssertEqual(searchResult.phrasionary?.title, expectedLearningCardMetaItem.title)
                XCTAssertEqual(searchResult.phrasionary?.body, expectedSnippet.description)
                if case .article(let aritcleItem) = searchResult.phrasionary?.targets.first {
                    XCTAssertEqual(aritcleItem.deepLink.learningCard, autoLinks[0].xid)
                }

                expectation.fulfill()
            case .failure:
                XCTFail("Should succeed with offline data")
            }
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenOnlineSearchFailsTheRepositoryCallsForOfflineArticleSearch() {
        appConfiguration.appVariant = .wissen
        searchClient.overviewSearchDEHandler = { _, _, _, completion in
            completion(.failure(.other(.fixture())))
        }
        let searchQuery = "spec_1_Somthing_To_Search"
        let autoLinks = [
            Autolink.fixture(phrase: searchQuery, xid: LearningCardIdentifier.fixture(value: "spec_1"), score: 0),
            Autolink.fixture(phrase: .fixture(), xid: .fixture(), score: .fixture())
        ]

        library.autolinks = autoLinks

        let expectedLearningCardMetaItem: LearningCardMetaItem = .fixture()
        library.learningCardMetaItemHandler = { _ in
            expectedLearningCardMetaItem
        }

        let expectation = self.expectation(description: "searchRepository search is called with search result")
        searchRepository.overviewSearch(for: searchQuery, requestTimeout: .fixture()) { result in
            switch result {
            case .success(let searchResult):
                switch searchResult.resultType {
                case .offline: break
                case .online: XCTFail("Unexpected result type")
                }

                XCTAssertEqual(searchResult.searchArticleResultItems.count, 1)
                XCTAssertEqual(searchResult.searchArticleResultsTotalCount, 1)

                if case let .article(articleItem) = searchResult.searchArticleResultItems[0] {
                    XCTAssertEqual(articleItem.title, autoLinks[0].phrase)
                    XCTAssertEqual(articleItem.body, expectedLearningCardMetaItem.title)
                    XCTAssertEqual(articleItem.deepLink.learningCard, autoLinks[0].xid)
                } else {
                    XCTFail("Should be an article result")
                }

                expectation.fulfill()
            case .failure:
                XCTFail("Should succeed with offline data")
            }
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatLibraryOfflineSearchItemsAreSortedByScoreWithDecendingOrder() {
        appConfiguration.appVariant = .wissen
        searchClient.overviewSearchDEHandler = { _, _, _, completion in
            completion(.failure(.other(.fixture())))
        }
        let searchQuery = "spec_1_Somthing_To_Search"
        let autoLinks = [
            Autolink.fixture(phrase: searchQuery, xid: LearningCardIdentifier.fixture(value: "spec_1"), score: 1),
            Autolink.fixture(phrase: searchQuery, xid: LearningCardIdentifier.fixture(value: "spec_2"), score: 5),
            Autolink.fixture(phrase: searchQuery, xid: LearningCardIdentifier.fixture(value: "spec_3"), score: 2)
        ]

        library.autolinks = autoLinks

        let expectedLearningCardMetaItem: LearningCardMetaItem = .fixture()
        library.learningCardMetaItemHandler = { _ in
            expectedLearningCardMetaItem
        }

        let expectation = self.expectation(description: "searchRepository search is called with search result")
        searchRepository.overviewSearch(for: searchQuery, requestTimeout: .fixture()) { result in
            switch result {
            case .success(let searchResult):
                switch searchResult.resultType {
                case .offline: break
                case .online: XCTFail("Unexpected result type")
                }

                XCTAssertEqual(searchResult.searchArticleResultItems.count, 3)
                XCTAssertEqual(searchResult.searchArticleResultsTotalCount, 3)

                if case let .article(articleItem) = searchResult.searchArticleResultItems[0] {
                    XCTAssertEqual(articleItem.deepLink.learningCard, autoLinks[1].xid)
                } else {
                    XCTFail("Should be an article result")
                }

                expectation.fulfill()
            case .failure:
                XCTFail("Should succeed with offline data")
            }
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenOnlineSearchFailsTheRepositoryCallsForOfflinePharmaSearchIfPharmaDatabaseIsAvailable() {
        appConfiguration.appVariant = .wissen
        searchClient.overviewSearchDEHandler = { _, _, _, completion in
            completion(.failure(.other(.fixture())))
        }
        let searchQuery = "spec_1_Somthing_To_Search"
        let expectedPharmaItems: [PharmaSearchItem] = [.fixture()]
        pharmaDatabase.itemsHandler = { _ in
            expectedPharmaItems
        }

        let expectation = self.expectation(description: "searchRepository search is called with search result")
        searchRepository.overviewSearch(for: searchQuery, requestTimeout: .fixture()) { result in
            switch result {
            case .success(let searchResult):
                switch searchResult.resultType {
                case .offline: break
                case .online: XCTFail("Unexpected result type")
                }

                XCTAssertEqual(searchResult.searchPharmaResultItems.count, 1)
                XCTAssertEqual(searchResult.searchPharmaResultsTotalCount, 1)

                if case let .pharma(pharmaItem) = searchResult.searchPharmaResultItems[0] {
                    XCTAssertEqual(pharmaItem.substanceID, expectedPharmaItems[0].substanceID)
                    XCTAssertEqual(pharmaItem.drugid, expectedPharmaItems[0].drugid)
                    XCTAssertEqual(pharmaItem.title, expectedPharmaItems[0].title)
                    XCTAssertEqual(pharmaItem.details, expectedPharmaItems[0].details)
                } else {
                    XCTFail("Should be a pharma result")
                }

                expectation.fulfill()
            case .failure:
                XCTFail("Should succeed with offline data")
            }
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenOnlineSearchFailsTheRepositoryCallsForOfflinePharmaSearchButDoesNotAddAnyPharmaItemsIfPharmaDatabaseIsNotAvailable() {
        pharmaService.pharmaDatabase = nil // -> No offline query possible now

        appConfiguration.appVariant = .wissen
        searchClient.overviewSearchDEHandler = { _, _, _, completion in
            completion(.failure(.other(.fixture())))
        }
        let searchQuery = "spec_1_Somthing_To_Search"
        let expectedPharmaItems: [PharmaSearchItem] = [.fixture()]
        pharmaDatabase.itemsHandler = { _ in
            expectedPharmaItems
        }

        let expectation = self.expectation(description: "searchRepository search is called with search result")
        searchRepository.overviewSearch(for: searchQuery, requestTimeout: .fixture()) { result in
            switch result {
            case .success(let searchResult):
                switch searchResult.resultType {
                case .offline: break
                case .online: XCTFail("Unexpected result type")
                }

                XCTAssertEqual(searchResult.searchPharmaResultItems.count, 0)
                XCTAssertEqual(searchResult.searchPharmaResultsTotalCount, 0)

                expectation.fulfill()
            case .failure:
                XCTFail("Should succeed with offline data")
            }
        }

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatFetchingExtraArticlesCallsTheClientWithTheRightParameters() {
        let expectedSearchQuery: String = .fixture()
        let expectedLimit: Int = .fixture()
        let expectedRequestTimeout: Double = .fixture()
        let expectedCursor: String? = .fixture()
        searchClient.getArticleResultsHandler = { searchQuery, limit, requestTimeout, cursor, _ in
            XCTAssertEqual(searchQuery, expectedSearchQuery)
            XCTAssertEqual(limit, expectedLimit)
            XCTAssertEqual(requestTimeout, expectedRequestTimeout)
            XCTAssertEqual(cursor, expectedCursor)
        }
        searchRepository.fetchArticleSearchResultPage(for: expectedSearchQuery, limit: expectedLimit, requestTimeout: expectedRequestTimeout, after: expectedCursor) { _ in }
    }

    func testThatFetchingExtraArticlesCompletesWithSuccessWhenClientCompletesWithSuccess() {
        let expectedPage = Page<ArticleSearchItem>(elements: .fixture(), nextPage: .fixture(), hasNextPage: .fixture())
        searchClient.getArticleResultsHandler = { _, _, _, _, completion in
            completion(.success(expectedPage))
        }

        searchRepository.fetchArticleSearchResultPage(for: .fixture(), limit: .fixture(), requestTimeout: .fixture(), after: .fixture()) { result in
            switch result {
            case .success(let page):
                XCTAssertEqual(page, expectedPage)
            case .failure:
                XCTFail()
            }
        }
    }

    func testThatFetchingExtraArticlesCompletesWithFailureWhenClientCompletesWithFailure() {
        let expectedError = NetworkError<EmptyAPIError>.failed(code: .fixture())
        searchClient.getArticleResultsHandler = { _, _, _, _, completion in
            completion(.failure(expectedError))
        }

        searchRepository.fetchArticleSearchResultPage(for: .fixture(), limit: .fixture(), requestTimeout: .fixture(), after: .fixture()) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                switch error {
                case SearchError.networkError(let networkError):
                    XCTAssertEqual(networkError.body, expectedError.body)
                default:
                    XCTFail()
                }
            }
        }
    }

    func testThatFetchingExtraPharmaCallsTheClientWithTheRightParameters() {
        let expectedSearchQuery: String = .fixture()
        let expectedLimit: Int = .fixture()
        let expectedRequestTimeout: Double = .fixture()
        let expectedCursor: String? = .fixture()
        searchClient.getPharmaResultsHandler = { searchQuery, limit, requestTimeout, cursor, _ in
            XCTAssertEqual(searchQuery, expectedSearchQuery)
            XCTAssertEqual(limit, expectedLimit)
            XCTAssertEqual(requestTimeout, expectedRequestTimeout)
            XCTAssertEqual(cursor, expectedCursor)
        }
        searchRepository.fetchPharmaSearchResultPage(for: expectedSearchQuery, limit: expectedLimit, requestTimeout: expectedRequestTimeout, after: expectedCursor) { _ in }
    }

    func testThatFetchingExtraPharmaItemsCompletesWithSuccessWhenClientCompletesWithSuccess() {
        let expectedPage = Page<PharmaSearchItem>(elements: .fixture(), nextPage: .fixture(), hasNextPage: .fixture())
        searchClient.getPharmaResultsHandler = { _, _, _, _, completion in
            completion(.success(expectedPage))
        }

        searchRepository.fetchPharmaSearchResultPage(for: .fixture(), limit: .fixture(), requestTimeout: .fixture(), after: .fixture()) { result in
            switch result {
            case .success(let page):
                XCTAssertEqual(page, expectedPage)
            case .failure:
                XCTFail()
            }
        }
    }

    func testThatFetchingExtraPharmaItemsCompletesWithFailureWhenClientCompletesWithFailure() {
        let expectedError = NetworkError<EmptyAPIError>.failed(code: .fixture())
        searchClient.getPharmaResultsHandler = { _, _, _, _, completion in
            completion(.failure(expectedError))
        }

        searchRepository.fetchPharmaSearchResultPage(for: .fixture(), limit: .fixture(), requestTimeout: .fixture(), after: .fixture()) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                switch error {
                case SearchError.networkError(let networkError):
                    XCTAssertEqual(networkError.body, expectedError.body)
                default:
                    XCTFail()
                }
            }
        }
    }

    func testThatFetchingExtraGuidelinesCallsTheClientWithTheRightParameters() {
        let expectedSearchQuery: String = .fixture()
        let expectedLimit: Int = .fixture()
        let expectedRequestTimeout: Double = .fixture()
        let expectedCursor: String? = .fixture()
        searchClient.getGuidelineResultsHandler = { searchQuery, limit, requestTimeout, cursor, _ in
            XCTAssertEqual(searchQuery, expectedSearchQuery)
            XCTAssertEqual(limit, expectedLimit)
            XCTAssertEqual(requestTimeout, expectedRequestTimeout)
            XCTAssertEqual(cursor, expectedCursor)
        }
        searchRepository.fetchGuidelineSearchResultPage(for: expectedSearchQuery, limit: expectedLimit, requestTimeout: expectedRequestTimeout, after: expectedCursor) { _ in }
    }

    func testThatFetchingExtraGuidelinesCompletesWithSuccessWhenClientCompletesWithSuccess() {
        let expectedPage = Page<GuidelineSearchItem>(elements: .fixture(), nextPage: .fixture(), hasNextPage: .fixture())
        searchClient.getGuidelineResultsHandler = { _, _, _, _, completion in
            completion(.success(expectedPage))
        }

        searchRepository.fetchGuidelineSearchResultPage(for: .fixture(), limit: .fixture(), requestTimeout: .fixture(), after: .fixture()) { result in
            switch result {
            case .success(let page):
                XCTAssertEqual(page, expectedPage)
            case .failure:
                XCTFail()
            }
        }
    }

    func testThatFetchingExtraGuidelineItemsCompletesWithFailureWhenClientCompletesWithFailure() {
        let expectedError = NetworkError<EmptyAPIError>.failed(code: .fixture())
        searchClient.getGuidelineResultsHandler = { _, _, _, _, completion in
            completion(.failure(expectedError))
        }

        searchRepository.fetchGuidelineSearchResultPage(for: .fixture(), limit: .fixture(), requestTimeout: .fixture(), after: .fixture()) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                switch error {
                case SearchError.networkError(let networkError):
                    XCTAssertEqual(networkError.body, expectedError.body)
                default:
                    XCTFail()
                }
            }
        }
    }

    func testThatFetchingExtraMediaItemsCallsTheClientWithTheRightParameters() {
        let expectedSearchQuery: String = .fixture()
        let expectedLimit: Int = .fixture()
        let expectedRequestTimeout: Double = .fixture()
        let expectedCursor: String? = .fixture()
        searchClient.getMediaResultsHandler = { searchQuery, _, limit, requestTimeout, cursor, _ in
            XCTAssertEqual(searchQuery, expectedSearchQuery)
            XCTAssertEqual(limit, expectedLimit)
            XCTAssertEqual(requestTimeout, expectedRequestTimeout)
            XCTAssertEqual(cursor, expectedCursor)
        }
        searchRepository.fetchMediaSearchResultPage(for: expectedSearchQuery, mediaFilters: [], limit: expectedLimit, requestTimeout: expectedRequestTimeout, after: expectedCursor) { _ in }
    }

    func testThatFetchingExtraMediItemsCompletesWithSuccessWhenClientCompletesWithSuccess() {
        let expectedPage = Page<MediaSearchItem>(elements: .fixture(), nextPage: .fixture(), hasNextPage: .fixture())
        searchClient.getMediaResultsHandler = { _, _, _, _, _, completion in
            completion(.success((expectedPage, .fixture())))
        }

        searchRepository.fetchMediaSearchResultPage(for: .fixture(), mediaFilters: [], limit: .fixture(), requestTimeout: .fixture(), after: .fixture()) { result in
            switch result {
            case .success((let page, _)):
                XCTAssertEqual(page, expectedPage)
            case .failure:
                XCTFail()
            }
        }
    }

    func testThatFetchingExtraMediaItemsCompletesWithFailureWhenClientCompletesWithFailure() {
        let expectedError = NetworkError<EmptyAPIError>.failed(code: .fixture())
        searchClient.getMediaResultsHandler = { _, _, _, _, _, completion in
            completion(.failure(expectedError))
        }

        searchRepository.fetchMediaSearchResultPage(for: .fixture(), mediaFilters: [], limit: .fixture(), requestTimeout: .fixture(), after: .fixture()) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                switch error {
                case SearchError.networkError(let networkError):
                    XCTAssertEqual(networkError.body, expectedError.body)
                default:
                    XCTFail()
                }
            }
        }
    }
}

extension Page: Equatable where T: Equatable {
    public static func == (lhs: Page<T>, rhs: Page<T>) -> Bool {
        lhs.elements == rhs.elements && lhs.nextPage == rhs.nextPage && lhs.hasNextPage == rhs.hasNextPage
    }
}
