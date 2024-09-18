//
//  SearchPresenterTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 01.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

import Common
import Foundation
import Domain
import Localization
import DesignSystem

class SearchPresenterTests: XCTestCase {
    var presenter: SearchPresenterType!
    var searchCoordinator: SearchCoordinatorTypeMock!
    var searchRepository: SearchRepositoryTypeMock!
    var pharmaRepository: PharmaRepositoryTypeMock!
    var suggestionRepository: SearchSuggestionRepositoryTypeMock!
    var searchHistoryRepository: SearchHistoryRepositoryTypeMock!
    var userDataRepository: UserDataRepositoryTypeMock!
    var featureFlagRepository: FeatureFlagRepositoryTypeMock!
    var remoteConfigRepository: RemoteConfigRepositoryTypeMock!
    var appConfiguration: ConfigurationMock!
    var userDataClient: UserDataClientMock!
    var shortcutsService: ShortcutsServiceTypeMock!
    var shortcutsRepository: ShortcutsRepositoryTypeMock!
    var mediaRepository: MediaRepositoryTypeMock!
    var galleryAnalyticsTrackingProvider: GalleryAnalyticsTrackingProviderTypeMock!
    var trackingProvider: TrackingTypeMock!
    var view: SearchViewTypeMock!

    override func setUp() {
        DesignSystem.initialize()
        view = SearchViewTypeMock()
        searchCoordinator = SearchCoordinatorTypeMock()
        searchRepository = SearchRepositoryTypeMock()
        suggestionRepository = SearchSuggestionRepositoryTypeMock()
        searchHistoryRepository = SearchHistoryRepositoryTypeMock()
        userDataRepository = UserDataRepositoryTypeMock()
        featureFlagRepository = FeatureFlagRepositoryTypeMock()
        appConfiguration = ConfigurationMock(appVariant: .wissen)
        remoteConfigRepository = RemoteConfigRepositoryTypeMock(searchAdConfig: SearchAdConfig())
        shortcutsService = ShortcutsServiceTypeMock()
        shortcutsRepository = ShortcutsRepositoryTypeMock()
        userDataClient = UserDataClientMock()
        pharmaRepository = PharmaRepositoryTypeMock()
        mediaRepository = MediaRepositoryTypeMock()
        galleryAnalyticsTrackingProvider = GalleryAnalyticsTrackingProviderTypeMock()
        trackingProvider = TrackingTypeMock()
        // Setting this handler here so that we don't need to set it every time we set the view on the presenter.
        shortcutsService.userActivityHandler = { _ in
            NSUserActivity(activityType: .fixture())
        }

        presenter = SearchPresenter(coordinator: searchCoordinator, searchRepository: searchRepository, searchSuggestionRepository: suggestionRepository, searchHistoryRepository: searchHistoryRepository, userDataRepository: userDataRepository, featureFlagRepository: featureFlagRepository, pharmaRepository: pharmaRepository, userDataClient: userDataClient, autocompleteTimerDelay: 0.0, trackingProvider: trackingProvider, supportRequestFactory: SupportRequestFactory(authorizationRepository: AuthorizationRepositoryTypeMock(), searchHistoryRepository: SearchHistoryRepositoryTypeMock(), libraryRepository: LibraryRepositoryTypeMock()), remoteConfigRepository: remoteConfigRepository, appConfiguration: appConfiguration, shortcutsService: shortcutsService, shortcutsRepository: shortcutsRepository, mediaRepository: mediaRepository, galleryTrackingProvider: galleryAnalyticsTrackingProvider)
    }
    override class func tearDown() {
        DesignSystem.deinitialize()
    }
    func testThatEditingSearchBarTextCallsSearchSessionStartedTrackingEvent() {
        let query: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchSessionStarted(_, let searchSessionQuery):
                    XCTAssertEqual(searchSessionQuery, query)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.searchBarTextDidChange(query: query)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatStartingSearchFromADeeplinkCallsSearchSessionStartedTrackingEvent() {
        let query = "ramipril"
        let webpageURL = URL(string: "https://next.amboss.com/de/search?q=\(query)&v=overview")!

        let expectation = self.expectation(description: "tracking event was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchSessionStarted(_, let searchSessionQuery):
                    XCTAssertEqual(searchSessionQuery, query)
                    expectation.fulfill()
                case .searchQueryCommitted: break
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.navigate(to: SearchDeeplink(url: webpageURL)!)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatFocusingOnSearchBarCallsSearchInputFieldFocusedTrackingEvent() {
        let input: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchInputFieldFocused(let currentInput, _, _):
                    XCTAssertEqual(currentInput, input)
                    expectation.fulfill()
                case .searchSessionStarted: break
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.searchBarTextFieldTapped(text: input)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatFocusingOnSearchBarCallsSearchSuggestionsShownTrackingEvent() {
        // Given
        let input: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")
        let suggestions = [SearchSuggestionItem.autocomplete(text: .fixture(), value: .fixture(), metadata: .fixture())]

        // This function is called only because of setting the property "queryText". if this property is nill code is returning to show the history
        presenter.searchBarTextDidChange(query: input)

        suggestionRepository.suggestionsHandler = { _, completion in
            completion(.fixture(resultType: .online, suggestions: suggestions))
        }

        // When & Then
        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchSuggestionsShown(let forInputValue, let currentInputValue, _, let searchSuggestions):
                    XCTAssertEqual(forInputValue, input)
                    XCTAssertEqual(currentInputValue, input)
                    XCTAssertEqual(searchSuggestions.description, suggestions.description)
                    expectation.fulfill()
                case .searchInputFieldFocused: break
                case .searchSessionStarted: break
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.searchBarTextFieldTapped(text: input)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatFocusingOnSearchBarInOfflineModeCallsSearchOfflineSuggestionsShownTrackingEvent() {
        // Given
        let input: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")
        let suggestions = [SearchSuggestionItem.autocomplete(text: .fixture(), value: .fixture(), metadata: .fixture())]

        // This function is called only because of setting the property "queryText". if this property is nill code is returning to show the history
        presenter.searchBarTextDidChange(query: input)

        suggestionRepository.suggestionsHandler = { _, completion in
            completion(.fixture(resultType: .offline, suggestions: suggestions))
        }

        // When & Then
        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchOfflineSuggestionsShown(_, let searchSessionQuery, let searchSuggestions):
                    XCTAssertEqual(searchSessionQuery, input)
                    XCTAssertEqual(searchSuggestions.description, suggestions.description)
                    expectation.fulfill()
                case .searchInputFieldFocused: break
                case .searchSessionStarted: break
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.searchBarTextFieldTapped(text: input)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatChangingInputOnSearchBarCallsSearchSuggestionsShownTrackingEvent() {
        let input: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")
        let suggestions = [SearchSuggestionItem.autocomplete(text: .fixture(), value: .fixture(), metadata: .fixture())]

        suggestionRepository.suggestionsHandler = { _, completion in
            completion(.fixture(resultType: .online, suggestions: suggestions))
        }
        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchSuggestionsShown(let forInputValue, let currentInputValue, _, let searchSuggestions):
                    XCTAssertEqual(forInputValue, input)
                    XCTAssertEqual(currentInputValue, input)
                    XCTAssertEqual(searchSuggestions.description, suggestions.description)
                    expectation.fulfill()
                case .searchInputFieldFocused: break
                case .searchSessionStarted: break
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.searchBarTextDidChange(query: input)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatSearchBarSearchButtonTappedCallsSarchQueryCommittedTrackingEvent() {
        let input: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchQueryCommitted(let fromSource, let instantTarget, let queryValue, _, _):
                    XCTAssertEqual(fromSource.rawValue, "input_value")
                    XCTAssertNil(instantTarget)
                    XCTAssertEqual(queryValue, input)
                    expectation.fulfill()
                case .searchOfflineQueryCommitted:
                    XCTFail("Unexpected event")
                default: break
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.searchBarSearchButtonTapped(query: input)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatSelectingAnAutoCompleteItemCallsSearchSuggestionsAppliedTrackingEvent() {
        let searchSuggestionsExpectation = self.expectation(description: "suggestionRepository was called to fetch search suggestions")
        let expectedSuggestions: [SearchSuggestionItem] = .fixture()
        suggestionRepository.suggestionsHandler = { _, completion in
            completion(SearchSuggestionResult(resultType: .online, suggestions: expectedSuggestions))
            searchSuggestionsExpectation.fulfill()
        }
        let query: String = .fixture()
        presenter.searchBarTextDidChange(query: query) // Trigger a call to suggestions
        wait(for: [searchSuggestionsExpectation], timeout: 0.1)

        let suggestion: AutocompleteViewItem = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchOfflineSuggestionApplied:
                    XCTFail("Unexpected event")
                case .searchSuggestionApplied(let currentInputValue, let method, let fromSuggestions, _, _):
                    XCTAssertEqual(currentInputValue, query)
                    XCTAssertEqual(method, .select)
                    XCTAssertEqual(fromSuggestions, expectedSuggestions)
                    expectation.fulfill()
                default: break
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: suggestion, query: query), at: 0, subIndex: nil)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatSelectingAnAutoCompleteItemFromOfflineSuggestionsCallsSearchOfflineSuggestionsAppliedTrackingEvent() {
        let searchSuggestionsExpectation = self.expectation(description: "suggestionRepository was called to fetch search suggestions")
        let expectedSuggestions: [SearchSuggestionItem] = .fixture()
        suggestionRepository.suggestionsHandler = { _, completion in
            completion(SearchSuggestionResult(resultType: .offline, suggestions: expectedSuggestions))
            searchSuggestionsExpectation.fulfill()
        }
        let query: String = .fixture()
        presenter.searchBarTextDidChange(query: query) // Trigger a call to suggestions
        wait(for: [searchSuggestionsExpectation], timeout: 0.1)

        let suggestion: AutocompleteViewItem = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchOfflineSuggestionApplied(let currentInputValue, let fromSuggestions, _, _):
                    XCTAssertEqual(currentInputValue, query)
                    XCTAssertEqual(fromSuggestions, expectedSuggestions)
                    expectation.fulfill()
                case .searchSuggestionApplied:
                    XCTFail("Unexpected event")
                default: break
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: suggestion, query: query), at: 0, subIndex: nil)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatSelectingAHistoryItemCallsSarchQueryCommittedTrackingEvent() {
        let input: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchQueryCommitted(let fromSource, let instantTarget, let queryValue, _, _):
                    XCTAssertEqual(fromSource.rawValue, "search_history")
                    XCTAssertNil(instantTarget)
                    XCTAssertEqual(queryValue, input)
                    expectation.fulfill()
                case .searchOfflineQueryCommitted:
                    XCTFail("Unexpected event")
                default: break
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didSelect(searchItem: .history(input), at: 0, subIndex: nil)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatSelectingAnAutoCompleteItemCallsSearchQueryCommittedTrackingEvent() {
        let suggestion: AutocompleteViewItem = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchQueryCommitted(let fromSource, let instantTarget, let queryValue, _, _):
                    XCTAssertEqual(fromSource.rawValue, "query_suggestion")
                    XCTAssertNil(instantTarget)
                    XCTAssertEqual(queryValue, suggestion.value)
                    expectation.fulfill()
                case .searchOfflineQueryCommitted:
                    XCTFail("Unexpected event")
                default: break
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: suggestion, query: .fixture()), at: 0, subIndex: nil)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatSelectingAnAutoCompleteItemCallsSearchOfflineQueryCommittedTrackingEvent() {
        let searchSuggestionsExpectation = self.expectation(description: "suggestionRepository was called to fetch search suggestions")
        suggestionRepository.suggestionsHandler = { _, completion in
            completion(SearchSuggestionResult(resultType: .offline, suggestions: .fixture()))
            searchSuggestionsExpectation.fulfill()
        }
        presenter.searchBarTextDidChange(query: .fixture()) // Trigger a call to suggestions
        wait(for: [searchSuggestionsExpectation], timeout: 0.1)

        let suggestion: AutocompleteViewItem = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchQueryCommitted:
                    XCTFail("Unexpected event")
                case .searchOfflineQueryCommitted(let fromSource, let instantTarget, let queryValue, _, _):
                    XCTAssertEqual(fromSource.rawValue, "query_suggestion")
                    XCTAssertNil(instantTarget)
                    XCTAssertEqual(queryValue, suggestion.value)
                    expectation.fulfill()
                default: break
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: suggestion, query: .fixture()), at: 0, subIndex: nil)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatSelectingAnInstantResultItemCallsSarchQueryCommittedTrackingEvent() {
        let text: NSAttributedString = .fixture()
        let trackingData: SearchSuggestionItem = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchQueryCommitted(let fromSource, let instantTarget, let queryValue, _, _):
                    XCTAssertEqual(fromSource.rawValue, "instant_result")
                    XCTAssertEqual(instantTarget, trackingData)
                    XCTAssertEqual(queryValue, text.string)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event")
                }
            case .article(let event):
                switch event {
                case .articleSelected: break
                default:  XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didSelect(searchItem: .instantResult(suggestedTerm: InstantResultViewItem(attributedText: text, value: .fixture(), type: .article(.fixture(), trackingData: trackingData)), query: .fixture()), at: 0, subIndex: nil)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatSelectingAnArticleFromInstantResultItemCallsArticleSelectedTrackingEvent() {
        let learningCardDeeplink: LearningCardDeeplink = .fixture()
        let suggestedTerm = InstantResultViewItem(attributedText: .fixture(), value: .fixture(), type: .article(learningCardDeeplink, trackingData: .fixture()))
        let expectation = self.expectation(description: "tracking event was called")

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleSelected(let articleID, let referrer):
                    XCTAssertEqual(learningCardDeeplink.learningCard.value, articleID)
                    XCTAssertEqual(referrer, .instantResults)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event")
                }
            case .search(let event):
                switch event {
                case .searchQueryCommitted: break
                default: XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didSelect(searchItem: .instantResult(suggestedTerm: suggestedTerm, query: .fixture()), at: 0, subIndex: nil)
        wait(for: [expectation], timeout: 0.1)
    }

    func testChangingScopeCallsSearchResultsShownTrackingEvent() {
        let input: String = .fixture()
        let correctedSearchTerm: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: .fixture(articleItems: [.fixture()], articleItemsTotalCount: 1, correctedSearchTerm: correctedSearchTerm))

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }
        presenter.searchBarSearchButtonTapped(query: input)

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchResultsShown(let didYouMean, let results, _, let searchSessionQuery, _, let view):
                    XCTAssertEqual(didYouMean, correctedSearchTerm)
                    XCTAssertEqual(results.first, expectedSearchResults.searchArticleResultItems.first?.resultUUID ?? "")
                    XCTAssertEqual(searchSessionQuery, input)
                    XCTAssertEqual(view.name, .articles)
                    expectation.fulfill()
                case .searchOfflineResultsShown:
                    XCTFail("Unexpected event")
                default: break
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didTapScope(.library(itemCount: 1), query: input)
        wait(for: [expectation], timeout: 0.1)
    }

    func testChangingScopeInOfflineModeCallsSarchOfflineResultsShownTrackingEvent() {
        let input: String = .fixture()
        let correctedSearchTerm: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        let expectedSearchResults = SearchResult.fixture(resultType: .offline(duration: .fixture()), searchOverviewResult: .fixture(articleItems: [.fixture()], articleItemsTotalCount: 1, correctedSearchTerm: correctedSearchTerm))

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }
        presenter.searchBarSearchButtonTapped(query: input)

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchOfflineResultsShown(_, _, let searchSessionQuery, let view):
                    XCTAssertEqual(searchSessionQuery, input)
                    XCTAssertEqual(view.name, .articles)
                    expectation.fulfill()
                case .searchResultsShown:
                    XCTFail("Unexpected event")
                default: break
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didTapScope(.library(itemCount: 1), query: input)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenSearchBarSearchButtonIsTapped_SarchResultsShownTrackingEventIsCalled_AfterTheResultsAreFetched() {
        let input: String = .fixture()
        let correctedSearchTerm: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        let phrasinoaryItem: PhrasionaryItem = .fixture()
        let articleItems: [ArticleSearchItem] = []
        let pharmaItems: [PharmaSearchItem] = []
        let guidelineItems: [GuidelineSearchItem] = [.fixture()]
        let mediaItems: [MediaSearchItem] = []

        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: phrasinoaryItem, articleItems: articleItems, articleItemsTotalCount: articleItems.count, pharmaInfo: .pharmaCard(pharmaItems: pharmaItems, pharmaItemsTotalCount: pharmaItems.count, pageInfo: nil), guidelineItems: guidelineItems, guidelineItemsTotalCount: guidelineItems.count, mediaItems: mediaItems, mediaItemsTotalCount: 0, correctedSearchTerm: correctedSearchTerm, targetScope: nil)

        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchResultsShown(let didYouMean, let results, _, let searchSessionQuery, _, let view):
                    XCTAssertEqual(didYouMean, correctedSearchTerm)
                    XCTAssertEqual(results.first, phrasinoaryItem.resultUUID)
                    XCTAssertEqual(results[1], expectedSearchResults.searchGuidelineResultItems.first?.resultUUID ?? "")
                    XCTAssertEqual(searchSessionQuery, input)
                    XCTAssertEqual(view.name, .overview)
                    expectation.fulfill()
                default: break
                }
            default:
              XCTFail("Unexpected event")
            }
        }
        presenter.searchBarSearchButtonTapped(query: input)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenSelectingAutoCompleteSearchSuggestionTapped_SarchResultsShownTrackingEventIsCalled_AfterTheResultsAreFetched() {
        let suggestion: AutocompleteViewItem = .fixture()
        let input: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")
        let correctedSearchTerm: String = .fixture()

        let phrasinoaryItem: PhrasionaryItem = .fixture()
        let articleItems: [ArticleSearchItem] = []
        let pharmaItems: [PharmaSearchItem] = []
        let guidelineItems: [GuidelineSearchItem] = []
        let mediaItems: [MediaSearchItem] = []

        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: phrasinoaryItem, articleItems: articleItems, articleItemsTotalCount: articleItems.count, pharmaInfo: .pharmaCard(pharmaItems: pharmaItems, pharmaItemsTotalCount: pharmaItems.count, pageInfo: nil), guidelineItems: guidelineItems, guidelineItemsTotalCount: guidelineItems.count, mediaItems: mediaItems, mediaItemsTotalCount: 0, correctedSearchTerm: correctedSearchTerm)

        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchResultsShown(let didYouMean, let results, _, let searchSessionQuery, _, let view):
                    XCTAssertEqual(didYouMean, correctedSearchTerm)
                    XCTAssertEqual(results.first, phrasinoaryItem.resultUUID)
                    XCTAssertEqual(searchSessionQuery, suggestion.value)
                    XCTAssertEqual(view.name, .overview)
                    expectation.fulfill()
                default: break
                }
            default:
              XCTFail("Unexpected event")
            }
        }
        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: suggestion, query: input), at: 0, subIndex: nil)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenHistoryItemTapped_SarchResultsShownTrackingEventIsCalled_AfterTheResultsAreFetched() {
        let input: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")
        let correctedSearchTerm: String = .fixture()
        let phrasinoaryItem: PhrasionaryItem = .fixture()
        let articleItems: [ArticleSearchItem] = []
        let pharmaItems: [PharmaSearchItem] = []
        let guidelineItems: [GuidelineSearchItem] = []
        let mediaItems: [MediaSearchItem] = []

        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: phrasinoaryItem, articleItems: articleItems, articleItemsTotalCount: articleItems.count, pharmaInfo: .pharmaCard(pharmaItems: pharmaItems, pharmaItemsTotalCount: pharmaItems.count, pageInfo: nil), guidelineItems: guidelineItems, guidelineItemsTotalCount: guidelineItems.count, mediaItems: mediaItems, mediaItemsTotalCount: 0, correctedSearchTerm: correctedSearchTerm)

        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchResultsShown(let didYouMean, let results, _, let searchSessionQuery, _, let view):
                    XCTAssertEqual(didYouMean, correctedSearchTerm)
                    XCTAssertEqual(results.first, expectedSearchResults.phrasionary?.resultUUID ?? "")
                    XCTAssertEqual(searchSessionQuery, input)
                    XCTAssertEqual(view.name, .overview)
                    expectation.fulfill()
                default: break
                }
            default:
              XCTFail("Unexpected event")
            }
        }
        presenter.didSelect(searchItem: .history(input), at: 0, subIndex: nil)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenNavigatedViaSearchViaDeeplink_SarchResultsShownTrackingEventIsCalled_AfterTheResultsAreFetched() {
        let query = "ramipril"
        let webpageURL = URL(string: "https://next.amboss.com/de/search?q=\(query)&v=overview")!
        let expectation = self.expectation(description: "tracking event was called")

        let phrasinoaryItem: PhrasionaryItem = .fixture()
        let articleItems: [ArticleSearchItem] = []
        let pharmaItems: [PharmaSearchItem] = []
        let guidelineItems: [GuidelineSearchItem] = []
        let mediaItems: [MediaSearchItem] = []

        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: phrasinoaryItem, articleItems: articleItems, articleItemsTotalCount: articleItems.count, pharmaInfo: .pharmaCard(pharmaItems: pharmaItems, pharmaItemsTotalCount: pharmaItems.count, pageInfo: nil), guidelineItems: guidelineItems, guidelineItemsTotalCount: guidelineItems.count, mediaItems: mediaItems, mediaItemsTotalCount: 0, correctedSearchTerm: nil)

        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchResultsShown(let didYouMean, _, _, let searchSessionQuery, _, let view):
                    XCTAssertNil(didYouMean)
                    XCTAssertEqual(searchSessionQuery, query)
                    XCTAssertEqual(view.name, .overview)
                    expectation.fulfill()
                case .searchSessionStarted: break
                case .searchQueryCommitted: break
                case .searchResultsViewChanged: break
                default:
                   XCTFail("Unexpected event")
                }
            default:
              XCTFail("Unexpected event")
            }
        }
        presenter.navigate(to: SearchDeeplink(url: webpageURL)!)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenOverviewSearchQueryFailedThenSearchResultsErrorShownTrackingEventCalled() {
        let query = "ramipril"
        let webpageURL = URL(string: "https://next.amboss.com/de/search?q=\(query)&v=overview")!
        let expectation = self.expectation(description: "tracking event was called")

        searchRepository.overviewSearchHandler  = { _, _, completion in
            completion(.failure(SearchError.networkError(.noInternetConnection)))
        }

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchResultsErrorShown(let error, _, let searchSessionQuery, _, let view):
                    XCTAssertNotNil(error)
                    XCTAssertEqual(searchSessionQuery, query)
                    XCTAssertEqual(view.name, .overview)
                    expectation.fulfill()
                case .searchSessionStarted: break
                case .searchQueryCommitted: break
                case .searchResultsViewChanged: break
                default:
                   XCTFail("Unexpected event")
                }
            default:
              XCTFail("Unexpected event")
            }
        }
        presenter.navigate(to: SearchDeeplink(url: webpageURL)!)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatChangingScopeCallsSearchResultsViewChangedTrackingEvent() {
        let input: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")
        presenter.didTapScope(.library(itemCount: 1), query: input)
        userDataRepository.hasConfirmedHealthCareProfession = true
        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchResultsViewChanged(let newView, let previousView, _, let searchSessionQuery, _):
                    XCTAssertEqual(newView.name, .pharma)
                    XCTAssertEqual(previousView.name, .articles)
                    XCTAssertEqual(searchSessionQuery, input)
                    expectation.fulfill()
                case .searchResultsShown: break
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didTapScope(.pharma(itemCount: 1), query: input)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatScrollingBottomCallsSearchResultsMoreRequestedForArticles() {
        let query: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        let searchOverviewResult: SearchOverviewResult = .fixture(articleItems: [.fixture()], articleItemsTotalCount: 1, mediaItems: [], mediaItemsTotalCount: 0)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }
        presenter.searchBarSearchButtonTapped(query: query)
        let newScope: SearchScope = .library(itemCount: 1)
        presenter.didTapScope(newScope, query: query)

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchResultsMoreRequested(let additionalNumberRequested, let currentResultCount, _, let searchSessionQuery, _, let view):
                    XCTAssertEqual(additionalNumberRequested, 10)
                    XCTAssertEqual(currentResultCount, 1)
                    XCTAssertEqual(searchSessionQuery, query)
                    XCTAssertEqual(view.name, .articles)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didScrollToBottom(with: .library(itemCount: 1))
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatScrollingBottomCallsSearchResultsMoreRequestedForGuidelines() {
        let query: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        let searchOverviewResult: SearchOverviewResult = .fixture(guidelineItems: [.fixture()], guidelineItemsTotalCount: 0, mediaItems: [], mediaItemsTotalCount: 0)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }
        presenter.searchBarSearchButtonTapped(query: query)
        let newScope: SearchScope = .guideline(itemCount: 1)
        presenter.didTapScope(newScope, query: query)

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchResultsMoreRequested(let additionalNumberRequested, let currentResultCount, _, let searchSessionQuery, _, let view):
                    XCTAssertEqual(additionalNumberRequested, 10)
                    XCTAssertEqual(currentResultCount, 1)
                    XCTAssertEqual(searchSessionQuery, query)
                    XCTAssertEqual(view.name, .guidelines)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didScrollToBottom(with: .guideline(itemCount: 1))
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatScrollingBottomCallsSearchResultsMoreRequestedForPharma() {
        let query: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        let searchOverviewResult: SearchOverviewResult = .fixture(pharmaInfo: .pharmaCard(pharmaItems: [.fixture()], pharmaItemsTotalCount: 1, pageInfo: .fixture()), mediaItems: [], mediaItemsTotalCount: 0)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }
        presenter.searchBarSearchButtonTapped(query: query)
        let newScope: SearchScope = .pharma(itemCount: 1)
        presenter.didTapScope(newScope, query: query)

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchResultsMoreRequested(let additionalNumberRequested, let currentResultCount, _, let searchSessionQuery, _, let view):
                    XCTAssertEqual(additionalNumberRequested, 10)
                    XCTAssertEqual(currentResultCount, 1)
                    XCTAssertEqual(searchSessionQuery, query)
                    XCTAssertEqual(view.name, .pharma)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didScrollToBottom(with: .pharma(itemCount: 1))
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatScrollingBottomCallsSearchResultsMoreRequestedForMedia() {
        let query: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        let searchOverviewResult: SearchOverviewResult = .fixture(mediaItems: [.fixture()], mediaItemsTotalCount: 1)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }
        presenter.searchBarSearchButtonTapped(query: query)
        let newScope: SearchScope = .media(itemCount: 1)
        presenter.didTapScope(newScope, query: query)

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchResultsMoreRequested(let additionalNumberRequested, let currentResultCount, _, let searchSessionQuery, _, let view):
                    XCTAssertEqual(additionalNumberRequested, 10)
                    XCTAssertEqual(currentResultCount, 1)
                    XCTAssertEqual(searchSessionQuery, query)
                    XCTAssertEqual(view.name, .media)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didScrollToBottom(with: .media(itemCount: 1))
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatSelectingPharmaSearchResultCallsSearchResultSelectedTrackingEvent() {
        let query: String = .fixture()
        let index: Int = 0
        let subIndex: Int? = nil
        let expectation = self.expectation(description: "tracking event was called")

        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: nil, pharmaInfo: .pharmaCard(pharmaItems: [.fixture()], pharmaItemsTotalCount: 1, pageInfo: .fixture()), mediaItems: [], mediaItemsTotalCount: 0, correctedSearchTerm: .fixture(), targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        presenter.view = view
        
        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchResultSelected(let fromView, _, let searchSessionQuery, _, let selectedIndex, let selectedSubIndex, let targetUuid):
                    XCTAssertEqual(targetUuid, expectedSearchResults.searchPharmaResultItems.first?.targetUUID ?? "")
                    XCTAssertEqual(fromView.name, .overview)
                    XCTAssertEqual(searchSessionQuery, query)
                    XCTAssertEqual(selectedIndex, index)
                    XCTAssertEqual(selectedSubIndex, subIndex)
                    expectation.fulfill()
                default: ()
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        
        view.showSectionsHandler = { sections, _, _ in
            if let item = sections.first?.items.first {
                self.presenter.didSelect(searchItem: item, at: index, subIndex: nil)
            }
        }
        
        presenter.searchBarSearchButtonTapped(query: query)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatSelectingGuidelineSearchResultCallsSearchResultSelectedTrackingEvent() {
        let query: String = .fixture()
        let targetUuid: String = .fixture()
        let didYouMean: String = .fixture()
        let index = 0
        let expectation = self.expectation(description: "tracking event was called")
        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: nil, articleItems: [], pharmaInfo: nil, guidelineItems: [.fixture(targetUUID: targetUuid)], guidelineItemsTotalCount: 1, mediaItems: [], mediaItemsTotalCount: 0, correctedSearchTerm: didYouMean, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }
        presenter.searchBarSearchButtonTapped(query: query)

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchResultSelected(let fromView, _, let searchSessionQuery, _, _, _, let targetUuid):
                    XCTAssertEqual(targetUuid, expectedSearchResults.searchGuidelineResultItems.first?.targetUUID ?? "")
                    XCTAssertEqual(fromView.name, .overview)
                    XCTAssertEqual(searchSessionQuery, query)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }
        presenter.didSelect(searchItem: SearchResultItemViewData.guideline(guidelineSearchViewItem: .fixture(targetUUid: targetUuid), query: query), at: index, subIndex: nil)
        wait(for: [expectation], timeout: 0.1)
    }
    func testThatSelectingArticleSearchResultCallsArticleSelectedTrackingEvent() {
        let query: String = .fixture()
        let articleSearchViewItem: ArticleSearchViewItem = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: nil, articleItems: [.fixture()], articleItemsTotalCount: 1, mediaItems: [], mediaItemsTotalCount: 0, correctedSearchTerm: .fixture(), targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }
        presenter.searchBarSearchButtonTapped(query: query)

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let event):
                switch event {
                case .articleSelected(let articleID, let referrer):
                    XCTAssertEqual(articleSearchViewItem.deeplink.learningCard.value, articleID)
                    XCTAssertEqual(referrer, .searchResults)
                    expectation.fulfill()
                default:  XCTFail("Unexpected event")
                }
            case .search(let event):
                switch event {
                case .searchResultSelected: break
                default: XCTFail("Unexpected event")
                }
            default: XCTFail("Unexpected event")
            }
        }
        presenter.didSelect(searchItem: SearchResultItemViewData.article(articleSearchViewItem: articleSearchViewItem, query: query), at: 0, subIndex: nil)
        wait(for: [expectation], timeout: 0.1)
    }
    func testThatSelectingArticleSearchResultCallsSearchResultSelectedTrackingEvent() {
        let query: String = .fixture()
        let didYouMean: String = .fixture()
        let index = 0
        let expectation = self.expectation(description: "tracking event was called")

        let targetUUID = String.fixture()
        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: nil, articleItems: [.fixture(targetUUID: targetUUID)], articleItemsTotalCount: 1, mediaItems: [], mediaItemsTotalCount: 0, correctedSearchTerm: didYouMean, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)
        
        let viewItem = ArticleSearchViewItem.fixture(targetUuid: targetUUID)
        
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }
        presenter.searchBarSearchButtonTapped(query: query)
        
        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchResultSelected(let fromView, _, let searchSessionQuery, _, let selectedIndex, _, let targetUuid):
                    XCTAssertEqual(targetUuid, expectedSearchResults.searchArticleResultItems.first?.targetUUID)
                    XCTAssertEqual(fromView.name, .overview)
                    XCTAssertEqual(searchSessionQuery, query)
                    XCTAssertEqual(selectedIndex, viewItem.resultIndex)
                    
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event")
                }
            case .article(let event):
                switch event {
                case .articleSelected: break
                default:  XCTFail("Unexpected event")
                }
            default: XCTFail("Unexpected event")
            }
        }
        presenter.didSelect(searchItem: SearchResultItemViewData.article(articleSearchViewItem: viewItem, query: query), at: index, subIndex: nil)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatSelectingArticleSearchResultInOfflineModeCallsSearchOfflineResultSelectedTrackingEvent() {
        let query: String = .fixture()
        let didYouMean: String = .fixture()
        let index = 0
        let expectation = self.expectation(description: "tracking event was called")

        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: nil, articleItems: [.fixture()], articleItemsTotalCount: 1, mediaItems: [], mediaItemsTotalCount: 0, correctedSearchTerm: didYouMean, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .offline(duration: .fixture()), searchOverviewResult: searchOverviewResult)
        
        let viewItem = ArticleSearchViewItem.fixture()
        
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }
        presenter.searchBarSearchButtonTapped(query: query)

        trackingProvider.trackHandler = { event in
            switch event {
            case .search(let event):
                switch event {
                case .searchOfflineResultSelected(let fromResults, let fromView, _, let searchSessionQuery, let selectedIndex, _):
                    XCTAssertEqual(fromResults.1, expectedSearchResults.searchArticleResultItems)
                    XCTAssertEqual(fromView.name, .overview)
                    XCTAssertEqual(searchSessionQuery, query)
                    XCTAssertEqual(selectedIndex, viewItem.resultIndex)
                    expectation.fulfill()
                default:
                    XCTFail("Unexpected event")
                }
            case .article(let event):
                switch event {
                case .articleSelected: break
                default:  XCTFail("Unexpected event")
                }
            default: XCTFail("Unexpected event")
            }
        }
        presenter.didSelect(searchItem: SearchResultItemViewData.article(articleSearchViewItem: viewItem, query: query), at: index, subIndex: nil)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenUserEnteredEmptyTextHistoryItemsAreShown() {
        presenter.view = view

        XCTAssertEqual(searchHistoryRepository.getSearchHistoryItemsCallCount, 1)

        let history = "spec_1"
        searchHistoryRepository.getSearchHistoryItemsHandler = {
            [history]
        }

        let expectation = self.expectation(description: "view set was called")
        view.showSectionsHandler = { sections, _, _ in
            XCTAssertEqual(sections.count, 1)
            XCTAssertEqual(sections[0].items.count, 1)
            if case .history = sections[0].items[0] {

            } else {
                XCTFail("Unexpected suggestion value")
            }
            expectation.fulfill()
        }

        presenter.searchBarTextDidChange(query: "")

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(searchHistoryRepository.getSearchHistoryItemsCallCount, 2)
    }

    func testThatWhenUserEnteredEmptyTextOfflineHintIsRemoved() {
        presenter.view = view
        XCTAssertEqual(view.hideOfflineHintCallCount, 0)

        presenter.searchBarTextDidChange(query: "")

        XCTAssertEqual(view.hideOfflineHintCallCount, 1)
    }

    func testThatWhenUserEnteredTextThenSuggestionsAreShown() {
        presenter.view = view
        let suggestion = "spec_1"
        let suggestions = [SearchSuggestionItem.autocomplete(text: suggestion, value: suggestion, metadata: .fixture())]
        suggestionRepository.suggestionsHandler = { _, completion in
            completion(.fixture(resultType: .fixture(), suggestions: suggestions))
        }

        let expectation = self.expectation(description: "view set was called")
        view.showSectionsHandler = { sections, _, _ in
            XCTAssertEqual(sections.count, 1)
            XCTAssertEqual(sections[0].items.count, 1)

            if case .autocomplete = sections.first?.items.first {

            } else {
                XCTFail("Unexpected suggestion value")
            }
            expectation.fulfill()
        }

        presenter.searchBarTextDidChange(query: "spe")

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(suggestionRepository.suggestionsCallCount, 1)
    }

//    func testThatWhenUserEnteredTextThenSuggestionsAreShownWithTheRightHighlightingInOfflineModeIfTheQueryMatchesTheBeginningOfTheSuggestion() {
//        presenter.view = view
//        let query = "spe"
//        let suggestion = "spec_1"
//        let suggestions = [SearchSuggestionItem.autocomplete(text: suggestion, value: suggestion, trackingData: .fixture())]
//        suggestionRepository.suggestionsHandler = { _, completion in
//            completion(.fixture(resultType: .offline, suggestions: suggestions))
//        }
//
//        let expectation = self.expectation(description: "view set was called")
//        view.showSectionsHandler = { sections, _, _ in
//            switch sections.first?.items.first {
//            case .autocomplete(let autocompleteViewItem, _):
//                let attributesForQuery = autocompleteViewItem.text.attributes(at: 0, effectiveRange: nil)
//                XCTAssertEqual(attributesForQuery[.font] as! UIFont, ThemeManager.currentTheme.searchSuggestionItemBoldTitleTextAttributes[.font] as! UIFont)
//                XCTAssertEqual(attributesForQuery[.foregroundColor] as! UIColor, ThemeManager.currentTheme.searchSuggestionItemBoldTitleTextAttributes[.foregroundColor] as! UIColor)
//
//                let attributesForCompletionText = autocompleteViewItem.text.attributes(at: 3, effectiveRange: nil)
//                XCTAssertEqual(attributesForCompletionText[.font] as! UIFont, ThemeManager.currentTheme.searchSuggestionItemNormalTitleTextAttributes[.font] as! UIFont)
//                XCTAssertEqual(attributesForCompletionText[.foregroundColor] as! UIColor, ThemeManager.currentTheme.searchSuggestionItemNormalTitleTextAttributes[.foregroundColor] as! UIColor)
//            default: XCTFail()
//            }
//
//            expectation.fulfill()
//        }
//
//        presenter.searchBarTextDidChange(query: query)
//
//        wait(for: [expectation], timeout: 0.2)
//    }

//    func testThatWhenUserEnteredTextThenSuggestionsAreShownWithTheRightHighlightingInOfflineModeIfTheQueryMatchesTheMiddleOfTheSuggestion() {
//        presenter.view = view
//        let query = "ec"
//        let suggestion = "spec_1"
//        let suggestions = [SearchSuggestionItem.autocomplete(text: suggestion, value: suggestion, trackingData: .fixture())]
//        suggestionRepository.suggestionsHandler = { _, completion in
//            completion(.fixture(resultType: .offline, suggestions: suggestions))
//        }
//
//        let expectation = self.expectation(description: "view set was called")
//        view.showSectionsHandler = { sections, _, _ in
//            switch sections.first?.items.first {
//            case .autocomplete(let autocompleteViewItem, _):
//                let attributesForCompletionTextFirstPart = autocompleteViewItem.text.attributes(at: 4, effectiveRange: nil)
//                XCTAssertEqual(attributesForCompletionTextFirstPart[.font] as! UIFont, ThemeManager.currentTheme.searchSuggestionItemNormalTitleTextAttributes[.font] as! UIFont)
//                XCTAssertEqual(attributesForCompletionTextFirstPart[.foregroundColor] as! UIColor, ThemeManager.currentTheme.searchSuggestionItemNormalTitleTextAttributes[.foregroundColor] as! UIColor)
//
//                let attributesForQuery = autocompleteViewItem.text.attributes(at: 2, effectiveRange: nil)
//                XCTAssertEqual(attributesForQuery[.font] as! UIFont, ThemeManager.currentTheme.searchSuggestionItemBoldTitleTextAttributes[.font] as! UIFont)
//                XCTAssertEqual(attributesForQuery[.foregroundColor] as! UIColor, ThemeManager.currentTheme.searchSuggestionItemBoldTitleTextAttributes[.foregroundColor] as! UIColor)
//
//                let attributesForCompletionTextSecondPart = autocompleteViewItem.text.attributes(at: 4, effectiveRange: nil)
//                XCTAssertEqual(attributesForCompletionTextSecondPart[.font] as! UIFont, ThemeManager.currentTheme.searchSuggestionItemNormalTitleTextAttributes[.font] as! UIFont)
//                XCTAssertEqual(attributesForCompletionTextSecondPart[.foregroundColor] as! UIColor, ThemeManager.currentTheme.searchSuggestionItemNormalTitleTextAttributes[.foregroundColor] as! UIColor)
//            default: XCTFail()
//            }
//
//            expectation.fulfill()
//        }
//
//        presenter.searchBarTextDidChange(query: query)
//
//        wait(for: [expectation], timeout: 0.2)
//    }

//    func testThatWhenUserEnteredTextThenSuggestionsAreShownWithTheRightHighlightingInOfflineModeIfTheQueryMatchesTheEndOfTheSuggestion() {
//        presenter.view = view
//        let query = "c_1"
//        let suggestion = "spec_1"
//        let suggestions = [SearchSuggestionItem.autocomplete(text: suggestion, value: suggestion, trackingData: .fixture())]
//        suggestionRepository.suggestionsHandler = { _, completion in
//            completion(.fixture(resultType: .offline, suggestions: suggestions))
//        }
//
//        let expectation = self.expectation(description: "view set was called")
//        view.showSectionsHandler = { sections, _, _ in
//            switch sections.first?.items.first {
//            case .autocomplete(let autocompleteViewItem, _):
//                let attributesForQuery = autocompleteViewItem.text.attributes(at: 3, effectiveRange: nil)
//                XCTAssertEqual(attributesForQuery[.font] as! UIFont, ThemeManager.currentTheme.searchSuggestionItemBoldTitleTextAttributes[.font] as! UIFont)
//                XCTAssertEqual(attributesForQuery[.foregroundColor] as! UIColor, ThemeManager.currentTheme.searchSuggestionItemBoldTitleTextAttributes[.foregroundColor] as! UIColor)
//
//                let attributesForCompletionText = autocompleteViewItem.text.attributes(at: 0, effectiveRange: nil)
//                XCTAssertEqual(attributesForCompletionText[.font] as! UIFont, ThemeManager.currentTheme.searchSuggestionItemNormalTitleTextAttributes[.font] as! UIFont)
//                XCTAssertEqual(attributesForCompletionText[.foregroundColor] as! UIColor, ThemeManager.currentTheme.searchSuggestionItemNormalTitleTextAttributes[.foregroundColor] as! UIColor)
//            default: XCTFail()
//            }
//
//            expectation.fulfill()
//        }
//
//        presenter.searchBarTextDidChange(query: query)
//
//        wait(for: [expectation], timeout: 0.2)
//    }

    func testThatWhenUserEnteredTextThenSearchScopesAreHidIfTheyWereShown() {
        presenter.view = view
        let suggestion = "spec_1"
        let suggestions = [SearchSuggestionItem.autocomplete(text: suggestion, value: suggestion, metadata: .fixture())]
        suggestionRepository.suggestionsHandler = { _, completion in
            completion(.fixture(resultType: .fixture(), suggestions: suggestions))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes was called")
        view.showAvailableSearchScopesHandler = { scopes in
            XCTAssertEqual(scopes.count, 0)
            expectation.fulfill()
        }

        presenter.searchBarTextDidChange(query: "spe")

        wait(for: [expectation], timeout: 0.3)
    }

    func testThatAfterSettingTheViewTheHistoryIsLoaded() {
        let storedHistoryItems: [String] = .fixture()
        searchHistoryRepository.getSearchHistoryItemsHandler = {
            storedHistoryItems
        }
        let expectation = self.expectation(description: "view setSearchHistoryItems was called")
        view.showSectionsHandler = { sections, _, _ in
            XCTAssertEqual(sections.count, 1)
            XCTAssertEqual(sections[0].items.count, storedHistoryItems.count)
            zip(storedHistoryItems, sections[0].items).forEach { item, viewItem in
                if case let .history(historyItem) = viewItem {
                    XCTAssertEqual(item, historyItem)
                }
            }

            expectation.fulfill()
        }

        presenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenASearchResultItemIsSelectedTheSearchCoordinatorIsAskedToNavigateToTheCorrectLearningCard() {
        presenter.view = view
        let articleSearchViewItem: ArticleSearchViewItem = .fixture()
        let expectation = self.expectation(description: "searchDelegate navigate to method was called")
        searchCoordinator.navigateToLearningCardDeeplinkHandler = { learningCard in
            XCTAssertEqual(learningCard.learningCard, articleSearchViewItem.deeplink.learningCard)
            XCTAssertEqual(learningCard.anchor, articleSearchViewItem.deeplink.anchor)
            XCTAssertEqual(learningCard.sourceAnchor, articleSearchViewItem.deeplink.sourceAnchor)
            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .article(articleSearchViewItem: articleSearchViewItem, query: .fixture()), at: 0, subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenASearchResultItemOfGuidelinesIsSelectedTheSearchCoordinatorIsAskedToOpenCorrectURL() {
        presenter.view = view
        let guidelineSearchViewItem: GuidelineSearchViewItem = .fixture()
        let expectation = self.expectation(description: "searchDelegate navigate to method was called")
        searchCoordinator.openURLInternallyHandler = { url in
            XCTAssertEqual(url, guidelineSearchViewItem.externalURL)
            expectation.fulfill()
        }
        presenter.didSelect(searchItem: .guideline(guidelineSearchViewItem: guidelineSearchViewItem, query: .fixture()), at: 0, subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatArticleScopeIsNotShownIfThereIsNoArticleResults() {
        presenter.view = view

        let phrasinoaryItem: PhrasionaryItem? = nil
        let articleItems: [ArticleSearchItem] = []
        let pharmaItems: [PharmaSearchItem] = [.fixture()]
        let guidelineItems: [GuidelineSearchItem] = [.fixture()]
        let mediaItems: [MediaSearchItem] = []

        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: phrasinoaryItem, articleItems: articleItems, articleItemsTotalCount: articleItems.count, pharmaInfo: .pharmaCard(pharmaItems: pharmaItems, pharmaItemsTotalCount: pharmaItems.count, pageInfo: nil), guidelineItems: guidelineItems, guidelineItemsTotalCount: guidelineItems.count, mediaItems: mediaItems, mediaItemsTotalCount: 0, targetScope: nil)

        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showAvailableSearchScopesHandler = { availableScopes in
            XCTAssertEqual(availableScopes.count, 3) // Overview, Pharma and Guideline in this case
            XCTAssertEqual(availableScopes[1], .pharma(itemCount: pharmaItems.count))
            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: .fixture(), query: .fixture()), at: 0, subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatGuidelineScopeIsNotShownIfThereIsNoGuidelineResults() {
        presenter.view = view

        let phrasinoaryItem: PhrasionaryItem? = nil
        let articleItems: [ArticleSearchItem] = []
        let pharmaItems: [PharmaSearchItem] = [.fixture()]
        let guidelineItems: [GuidelineSearchItem] = []
        let mediaItems: [MediaSearchItem] = []

        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: phrasinoaryItem, articleItems: articleItems, articleItemsTotalCount: articleItems.count, pharmaInfo: .pharmaCard(pharmaItems: pharmaItems, pharmaItemsTotalCount: pharmaItems.count, pageInfo: nil), guidelineItems: guidelineItems, guidelineItemsTotalCount: guidelineItems.count, mediaItems: mediaItems, mediaItemsTotalCount: 0, targetScope: nil)

        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showAvailableSearchScopesHandler = { availableScopes in
            XCTAssertEqual(availableScopes.count, 2) // Overview and Pharma in this case
            XCTAssertEqual(availableScopes[0], .overview)
            XCTAssertEqual(availableScopes[1], .pharma(itemCount: pharmaItems.count))
            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: .fixture(), query: .fixture()), at: 0, subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatMediaScopeIsNotShownIfThereIsNoMediaResults() {
        presenter.view = view

        let phrasinoaryItem: PhrasionaryItem? = nil
        let articleItems: [ArticleSearchItem] = []
        let pharmaItems: [PharmaSearchItem] = [.fixture()]
        let guidelineItems: [GuidelineSearchItem] = []
        let mediaItems: [MediaSearchItem] = []

        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: phrasinoaryItem, articleItems: articleItems, articleItemsTotalCount: articleItems.count, pharmaInfo: .pharmaCard(pharmaItems: pharmaItems, pharmaItemsTotalCount: pharmaItems.count, pageInfo: nil), guidelineItems: guidelineItems, guidelineItemsTotalCount: guidelineItems.count, mediaItems: mediaItems, mediaItemsTotalCount: 0, targetScope: nil)

        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showAvailableSearchScopesHandler = { availableScopes in
            XCTAssertEqual(availableScopes.count, 2) // Overview and Pharma in this case
            XCTAssertEqual(availableScopes[0], .overview)
            XCTAssertEqual(availableScopes[1], .pharma(itemCount: pharmaItems.count))
            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: .fixture(), query: .fixture()), at: 0, subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatMediaScopeIsShownIfThereAreMediaResults() {
        presenter.view = view

        let phrasinoaryItem: PhrasionaryItem? = nil
        let articleItems: [ArticleSearchItem] = []
        let pharmaItems: [PharmaSearchItem] = []
        let guidelineItems: [GuidelineSearchItem] = []
        let mediaItems: [MediaSearchItem] = [.fixture()]

        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: phrasinoaryItem, articleItems: articleItems, articleItemsTotalCount: articleItems.count, pharmaInfo: .pharmaCard(pharmaItems: pharmaItems, pharmaItemsTotalCount: pharmaItems.count, pageInfo: nil), guidelineItems: guidelineItems, guidelineItemsTotalCount: guidelineItems.count, mediaItems: mediaItems, mediaItemsTotalCount: 1, targetScope: nil)

        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showAvailableSearchScopesHandler = { availableScopes in
            XCTAssertEqual(availableScopes.count, 2) // Overview and media in this case
            XCTAssertEqual(availableScopes[0], .overview)
            XCTAssertEqual(availableScopes[1], .media(itemCount: mediaItems.count))
            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: .fixture(), query: .fixture()), at: 0, subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatPharmaScopeIsNotShownIfThereIsNoPharmaResults() {
        presenter.view = view

        let phrasinoaryItem: PhrasionaryItem? = nil
        let articleItems: [ArticleSearchItem] = [.fixture()]
        let pharmaItems: [PharmaSearchItem] = []
        let guidelineItems: [GuidelineSearchItem] = []
        let mediaItems: [MediaSearchItem] = []

        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: phrasinoaryItem, articleItems: articleItems, articleItemsTotalCount: articleItems.count, pharmaInfo: .pharmaCard(pharmaItems: pharmaItems, pharmaItemsTotalCount: pharmaItems.count, pageInfo: nil), guidelineItems: guidelineItems, guidelineItemsTotalCount: guidelineItems.count, mediaItems: mediaItems, mediaItemsTotalCount: 0, targetScope: nil)

        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showAvailableSearchScopesHandler = { availableScopes in
            XCTAssertEqual(availableScopes.count, 2) // Overview and Articles in this case
            XCTAssertEqual(availableScopes[1], .library(itemCount: articleItems.count))
            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: .fixture(), query: .fixture()), at: 0, subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatOverviewScopeIsShownEvenIfWeHavePhrasionaryOnly() {
        presenter.view = view

        let phrasinoaryItem: PhrasionaryItem = .fixture()
        let articleItems: [ArticleSearchItem] = []
        let pharmaItems: [PharmaSearchItem] = []
        let guidelineItems: [GuidelineSearchItem] = []
        let mediaItems: [MediaSearchItem] = []

        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: phrasinoaryItem, articleItems: articleItems, articleItemsTotalCount: articleItems.count, pharmaInfo: .pharmaCard(pharmaItems: pharmaItems, pharmaItemsTotalCount: pharmaItems.count, pageInfo: nil), guidelineItems: guidelineItems, guidelineItemsTotalCount: guidelineItems.count, mediaItems: mediaItems, mediaItemsTotalCount: 0, targetScope: nil)

        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showAvailableSearchScopesHandler = { availableScopes in
            XCTAssertEqual(availableScopes.count, 1) // Overview and phrasionary
            XCTAssertEqual(availableScopes[0], .overview)
            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: .fixture(), query: .fixture()), at: 0, subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenSuggestionIsSelectedThenViewIsSetWithResults() {
        presenter.view = view
        let searchOverviewResult: SearchOverviewResult = .fixture(articleItems: [.fixture(), .fixture()], articleItemsTotalCount: 2, mediaItems: [], mediaItemsTotalCount: 0, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showSectionsHandler = { sections, _, _ in
            XCTAssertEqual(sections.count, self.expectedOverviewSectionsCount(for: searchOverviewResult))
            self.verifyOverviewScopeContent(sections, for: searchOverviewResult)

            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: .fixture(), query: .fixture()), at: 0, subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenSuggestionIsSelectedTheSearchBarIsSetToTheSelectedHistoryItemText() {
        presenter.view = view

        let suggestionItem: AutocompleteViewItem = .fixture()

        let exp = expectation(description: "setSearchTextFieldText is called")

        view.setSearchTextFieldTextHandler = { text in
            XCTAssertEqual(suggestionItem.value, text)
            exp.fulfill()
        }

        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: suggestionItem, query: .fixture()), at: 0, subIndex: nil)

        wait(for: [exp], timeout: 0.1)
    }

    func testThatWhenSuggestionIsSelectedTheViewIsAskedToHideTheKeyboard() {
        presenter.view = view

        let suggestionItem: AutocompleteViewItem = .fixture()

        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: suggestionItem, query: .fixture()), at: 0, subIndex: nil)

        XCTAssertEqual(view.hideKeyboardCallCount, 1)
    }

    func testThatWhenHistoryItemIsSelectedThenViewIsSetWithResults() {
        presenter.view = view
        let searchOverviewResult: SearchOverviewResult = .fixture(articleItems: [.fixture(), .fixture()], articleItemsTotalCount: 2, mediaItems: [], mediaItemsTotalCount: 0, targetScope: nil)

        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showSectionsHandler = { sections, _, _ in
            XCTAssertEqual(sections.count, self.expectedOverviewSectionsCount(for: searchOverviewResult))
            self.verifyOverviewScopeContent(sections, for: searchOverviewResult)

            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .history(.fixture()), at: 0, subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenHistoryItemIsSelectedAndThereWasAScopeSelectedPreviously_ThenOnSuccessViewIsSetWithTheContentOfSearchResultsThatIsRelevantToTheLastSelectedSearchScopeIfThereWereAny() {
        presenter.view = view

        let lastSelectedSearchScope: SearchScope = .library(itemCount: .fixture())
        presenter.didTapScope(lastSelectedSearchScope, query: .fixture())
        
        let searchOverviewResult: SearchOverviewResult = .fixture(articleItems: [.fixture()], articleItemsTotalCount: 1, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showSectionsHandler = { sections, _, scope in
            switch scope {
            case .library:
                XCTAssertEqual(sections.count, 1)
                self.verifyArticleSection(sections[0], for: searchOverviewResult)
            default:
                XCTFail()
            }

            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .history(.fixture()), at: 0, subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenHistoryItemIsSelectedAndThereWasAScopeSelectedPreviouslyAndTargetViewWasNil_ThenOnSuccessViewIsSetWithTheContentOfSearchResultsOverview_IfThereWasNoResultsRelevantToTheLastSelectedSearchScope() {
        presenter.view = view

        let lastSelectedSearchScope: SearchScope = .library(itemCount: .fixture())
        presenter.didTapScope(lastSelectedSearchScope, query: .fixture())

        let searchOverviewResult: SearchOverviewResult = .fixture(articleItems: [], articleItemsTotalCount: 0, mediaItems: [], mediaItemsTotalCount: 0, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showSectionsHandler = { sections, _, _ in
            XCTAssertEqual(sections.count, self.expectedOverviewSectionsCount(for: searchOverviewResult))
            self.verifyOverviewScopeContent(sections, for: searchOverviewResult)

            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .history(.fixture()), at: 0, subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenAutocompleteItemIsSelectedAndThereWasAScopeSelectedPreviouslyAndTargetViewIsNil_ThenOnSuccessViewIsSetWithTheContentOfSearchResultsThatIsRelevantToTheLastSelectedSearchScopeIfThereWereAny() {
        presenter.view = view

        let lastSelectedSearchScope: SearchScope = .library(itemCount: .fixture())
        presenter.didTapScope(lastSelectedSearchScope, query: .fixture())

        let searchOverviewResult: SearchOverviewResult = .fixture(articleItems: [.fixture()], articleItemsTotalCount: 1, mediaItems: [], mediaItemsTotalCount: 0, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showSectionsHandler = { sections, _, _ in
            switch lastSelectedSearchScope {
            case .library:
                XCTAssertEqual(sections.count, 1)
                self.verifyArticleSection(sections[0], for: searchOverviewResult)
            default:
                XCTFail()
            }

            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: .fixture(), query: .fixture()), at: .fixture(), subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenAutocompleteItemIsSelectedThenViewIsSetWithResultsAndThereWasAScopeSelectedPreviously_ThenOnSuccessViewIsSetWithTheContentOfSearchResultsOverview_IfThereNoResultsRelevantToTheLastSelectedSearchScope() {
        presenter.view = view

        let lastSelectedSearchScope: SearchScope = .library(itemCount: .fixture())
        presenter.didTapScope(lastSelectedSearchScope, query: .fixture())

        let searchOverviewResult: SearchOverviewResult = .fixture(articleItems: [], articleItemsTotalCount: 0, mediaItems: [], mediaItemsTotalCount: 0, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showSectionsHandler = { sections, _, _ in
            XCTAssertEqual(sections.count, self.expectedOverviewSectionsCount(for: searchOverviewResult))
            self.verifyOverviewScopeContent(sections, for: searchOverviewResult)

            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: .fixture(), query: .fixture()), at: .fixture(), subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenHistoryItemIsSelectedTheSearchBarIsSetToTheSelectedHistoryItemText() {
        presenter.view = view

        let historyItem: String = .fixture()
        let exp = expectation(description: "setSearchTextFieldText is called")

        view.setSearchTextFieldTextHandler = { text in
            XCTAssertEqual(historyItem, text)
            exp.fulfill()
        }

        presenter.didSelect(searchItem: .history(historyItem), at: 0, subIndex: nil)

        wait(for: [exp], timeout: 0.1)
    }

    func testThatWhenHistoryItemIsSelectedTheViewIsAskedToHideTheKeyboard() {
        presenter.view = view

        let historyItem: String = .fixture()

        presenter.didSelect(searchItem: .history(historyItem), at: 0, subIndex: nil)

        XCTAssertEqual(view.hideKeyboardCallCount, 1)
    }

    func testThatWhenSearchBarSearchButtonIsTappedWithArticleAsTheSelectedSearchScopeAndTargetViewIsNilThenArticleSearchIsCalledAndTheContentOfArticleTabIsPassed() {
        presenter.view = view
        
        let searchOverviewResult: SearchOverviewResult = .fixture(articleItems: [.fixture(), .fixture()], articleItemsTotalCount: 2, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)
        presenter.didTapScope(.library(itemCount: 1), query: .fixture())
        
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showSectionsHandler = { sections, _, scope in
            XCTAssertEqual(sections.count, 1)
            self.verifyArticleSection(sections[0], for: searchOverviewResult)

            expectation.fulfill()
        }

        presenter.searchBarSearchButtonTapped(query: .fixture())

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenSearchBarSearchButtonIsTappedWithPharmaAsTheSelectedSearchScopeThenPharmaSearchIsCalled() {
        presenter.view = view
        userDataRepository.hasConfirmedHealthCareProfession = true
        let searchOverviewResult: SearchOverviewResult = .fixture(pharmaInfo: .pharmaCard(pharmaItems: [.fixture(), .fixture()], pharmaItemsTotalCount: 2, pageInfo: nil), targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)
        presenter.didTapScope(SearchScope.pharma(itemCount: .fixture()), query: .fixture())
        
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showSectionsHandler = { sections, _, scope in
            XCTAssertEqual(sections.count, 1)
            self.verifyPharmaSection(sections[0], for: searchOverviewResult)

            expectation.fulfill()
        }

        presenter.searchBarSearchButtonTapped(query: .fixture())

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenSearchBarSearchButtonIsTappedWithoutASelectedSearchScopeAndTargetViewIsNilThenOnSuccessViewIsSetWithOverviewContentOfSearchResults() {
        presenter.view = view

        let searchOverviewResult: SearchOverviewResult = .fixture(articleItems: [.fixture(), .fixture()], articleItemsTotalCount: 2, mediaItems: [], mediaItemsTotalCount: 0, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showSectionsHandler = { sections, _, _ in
            XCTAssertEqual(sections.count, self.expectedOverviewSectionsCount(for: searchOverviewResult))
            self.verifyOverviewScopeContent(sections, for: searchOverviewResult)

            expectation.fulfill()
        }

        presenter.searchBarSearchButtonTapped(query: .fixture())

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenThereIsAPreviouslySelectedScopeAndSearchButtonIsTappedAndTargetViewIsNil_ThenOnSuccessViewIsSetWithTheContentOfSearchResultsThatIsRelevantToTheLastSelectedSearchScope_IfTheSearchResultsContainedResultsRelevantToTheLastSelectedScope() {
        presenter.view = view

        let lastSelectedSearchScope: SearchScope = .library(itemCount: .fixture())
        presenter.didTapScope(lastSelectedSearchScope, query: .fixture())

        let searchOverviewResult: SearchOverviewResult = .fixture(articleItems: [.fixture()], articleItemsTotalCount: 1, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showSectionsHandler = { sections, _, _ in
            switch lastSelectedSearchScope {
            case .library:
                XCTAssertEqual(sections.count, 1)
                self.verifyArticleSection(sections[0], for: searchOverviewResult)
            default:
                XCTFail()
            }

            expectation.fulfill()
        }

        presenter.searchBarSearchButtonTapped(query: .fixture())

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenThereIsAPreviouslySelectedScopeAndSearchButtonIsTapped_ThenOnSuccessViewIsSetWithTheOverviewSearchResult_IfTheSearchResultsDidNotContainResultsRelevantToTheLastSelectedScope() {
        presenter.view = view

        let lastSelectedSearchScope: SearchScope = .library(itemCount: .fixture())
        presenter.didTapScope(lastSelectedSearchScope, query: .fixture())

        let searchOverviewResult: SearchOverviewResult = .fixture(articleItems: [], articleItemsTotalCount: 0, mediaItems: [], mediaItemsTotalCount: 0, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showSectionsHandler = { sections, _, _ in
            XCTAssertEqual(sections.count, self.expectedOverviewSectionsCount(for: searchOverviewResult))
            self.verifyOverviewScopeContent(sections, for: searchOverviewResult)

            expectation.fulfill()
        }

        presenter.searchBarSearchButtonTapped(query: .fixture())

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenOverviewSearchSucceedsWithEmptyResultsNoResultsViewIsShown() {
        presenter.view = view

        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: nil, articleItems: [], articleItemsTotalCount: 0, pharmaInfo: .pharmaCard(pharmaItems: [], pharmaItemsTotalCount: 0, pageInfo: nil), mediaItems: [], mediaItemsTotalCount: 0, correctedSearchTerm: nil, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        XCTAssertEqual(view.showNoResultViewCallCount, 0)

        let expectation = self.expectation(description: "overviewSearch completion handler is called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: .fixture(), query: .fixture()), at: 0, subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(view.showNoResultViewCallCount, 1)
    }

    func testThatWhenThereAreMediaResultsThenOverviewSearchShowsMediaSections() {
        presenter.view = view
        let mediaSearchItem: [MediaSearchItem] = [.fixture()]
        let searchOverviewResult: SearchOverviewResult = .fixture(mediaItems: mediaSearchItem, mediaItemsTotalCount: mediaSearchItem.count, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view showAvailableSearchScopes is called")
        view.showSectionsHandler = { sections, _, _ in
            XCTAssertEqual(sections.count, self.expectedOverviewSectionsCount(for: searchOverviewResult))
            self.verifyOverviewScopeContent(sections, for: searchOverviewResult)
            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .autocomplete(suggestedTerm: .fixture(), query: .fixture()), at: 0, subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenAPharmaItemIsSelectedTheSearchCoordinatorIsAskedToNavigateToASpecificAgentAndDrug() {
        presenter.view = view
        let pharmaSearchViewItem: PharmaSearchViewItem = .fixture()

        let expectation = self.expectation(description: "Coordinator is asked to navigate to the required agent")

        searchCoordinator.navigateToDrugHandler = { substanceID, drugId in
            XCTAssertEqual(pharmaSearchViewItem.substanceID, substanceID)
            XCTAssertEqual(pharmaSearchViewItem.drugId, drugId)
            expectation.fulfill()
        }

        presenter.didSelect(searchItem: .pharma(pharmaSearchViewItem: pharmaSearchViewItem, query: .fixture(), database: .online), at: .fixture(), subIndex: nil)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenADidYouMeanTermIsSuggestedTheDidYouMeanViewIsShownWithTheCorrectValue() {
        presenter.view = view

        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: .fixture(articleItems: [.fixture()], articleItemsTotalCount: 1, correctedSearchTerm: "spec_some_Suggestions_in", targetScope: nil))

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        let expectation = self.expectation(description: "view setSearchResults is called")
        view.showDidYouMeanViewIfNeededHandler = { _, didYouMean in
            XCTAssertEqual(expectedSearchResults.correctedSearchTerm, didYouMean)
            expectation.fulfill()
        }

        presenter.searchBarSearchButtonTapped(query: "spec_some_Suggestions")

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatCallingNavigateToSearchDeepLinkForOverviewTriggersSearch() {
        // Given
        let url = URL(string: "https://next.amboss.com/de/search?q=ramipril&v=overview")!
        let searchDeeplink = SearchDeeplink(url: url)!
        presenter.view = view

        let searchOverviewResult: SearchOverviewResult = .fixture()
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        let expectation = self.expectation(description: "overviewSearch is called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            expectation.fulfill()
        }

        // When
        presenter.navigate(to: searchDeeplink)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatCallingNavigateToSearchDeepLinkForOverviewUpdatesSelectedScope() {
        // Given
        let url = URL(string: "https://next.amboss.com/de/search?q=ramipril&v=overview")!
        let searchDeeplink = SearchDeeplink(url: url)!
        presenter.view = view

        let searchOverviewResult: SearchOverviewResult = .fixture()
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        let expectation = self.expectation(description: "overviewSearch is called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            expectation.fulfill()
        }

        // Call count before navigating to search deeplink
        XCTAssertEqual(view.changeSelectedScopeCallCount, 0)

        // When
        presenter.navigate(to: searchDeeplink)

        wait(for: [expectation], timeout: 0.1)
        // Then Triggering Search calls changeSelectedScope
        XCTAssertEqual(view.changeSelectedScopeCallCount, 1)
    }

    func testThatCallingNavigateToSearchDeepLinkForArticleTriggersSearch() {
        // Given
        let url = URL(string: "https://next.amboss.com/de/search?q=ramipril&v=article")!
        let searchDeeplink = SearchDeeplink(url: url)!
        presenter.view = view

        let searchOverviewResult: SearchOverviewResult = .fixture()
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        let expectation = self.expectation(description: "overviewSearch is called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            expectation.fulfill()
        }

        // When
        presenter.navigate(to: searchDeeplink)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatCallingNavigateToSearchDeepLinkForArticleUpdatesSelectedScope() {
        // Given
        let url = URL(string: "https://next.amboss.com/de/search?q=ramipril&v=article")!
        let searchDeeplink = SearchDeeplink(url: url)!
        presenter.view = view

        let searchOverviewResult: SearchOverviewResult = .fixture(articleItems: [.fixture()], articleItemsTotalCount: 1, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        let expectation = self.expectation(description: "overviewSearch is called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            expectation.fulfill()
        }

        // Call count before navigating to search deeplink
        XCTAssertEqual(view.changeSelectedScopeCallCount, 0)

        // When
        presenter.navigate(to: searchDeeplink)

        wait(for: [expectation], timeout: 0.1)
        // Then Triggering Search calls changeSelectedScope
        XCTAssertEqual(view.changeSelectedScopeCallCount, 1)
    }

    func testThatCallingNavigateToSearchDeepLinkForPharmaTriggersSearch() {
        // Given
        appConfiguration.appVariant = .wissen
        userDataRepository.hasConfirmedHealthCareProfession = true
        let url = URL(string: "https://next.amboss.com/de/search?q=ramipril&v=pharma")!
        let searchDeeplink = SearchDeeplink(url: url)!
        presenter.view = view

        let searchOverviewResult: SearchOverviewResult = .fixture()
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        let expectation = self.expectation(description: "overviewSearch is called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            expectation.fulfill()
        }

        // When
        presenter.navigate(to: searchDeeplink)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatCallingNavigateToSearchDeepLinkForPharmaUpdatesSelectedScope() {
        // Given
        appConfiguration.appVariant = .wissen
        userDataRepository.hasConfirmedHealthCareProfession = true
        let url = URL(string: "https://next.amboss.com/de/search?q=ramipril&v=pharma")!
        let searchDeeplink = SearchDeeplink(url: url)!
        presenter.view = view

        let searchOverviewResult: SearchOverviewResult = .fixture(pharmaInfo: .pharmaCard(pharmaItems: [.fixture()], pharmaItemsTotalCount: 1, pageInfo: nil), targetScope: nil)
        print("%% testThatCallingNavigateToSearchDeepLinkForPharmaUpdatesSelectedScope searchOverviewResult: \(searchOverviewResult)")
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        let expectation = self.expectation(description: "overviewSearch is called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            expectation.fulfill()
        }

        // Call count before navigating to search deeplink
        XCTAssertEqual(view.changeSelectedScopeCallCount, 0)

        // When
        presenter.navigate(to: searchDeeplink)

        wait(for: [expectation], timeout: 0.1)
        // Then Triggering Search calls changeSelectedScope
        XCTAssertEqual(view.changeSelectedScopeCallCount, 1)
    }

    func testThatCallingNavigateToSearchDeepLinkForGuidelineTriggersSearch() {
        // Given
        let url = URL(string: "https://next.amboss.com/de/search?q=diabetes&v=guideline")!
        let searchDeeplink = SearchDeeplink(url: url)!
        presenter.view = view

        let searchOverviewResult: SearchOverviewResult = .fixture()
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        let expectation = self.expectation(description: "overviewSearch is called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            expectation.fulfill()
        }

        // When
        presenter.navigate(to: searchDeeplink)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatCallingNavigateToSearchDeepLinkForGuidelineUpdatesSelectedScope() {
        // Given
        let url = URL(string: "https://next.amboss.com/de/search?q=diabetes&v=guideline")!
        let searchDeeplink = SearchDeeplink(url: url)!
        presenter.view = view

        let searchOverviewResult: SearchOverviewResult = .fixture(guidelineItems: [.fixture()], guidelineItemsTotalCount: 1, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        let expectation = self.expectation(description: "overviewSearch is called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            expectation.fulfill()
        }

        // Call count before navigating to search deeplink
        XCTAssertEqual(view.changeSelectedScopeCallCount, 0)

        // When
        presenter.navigate(to: searchDeeplink)

        wait(for: [expectation], timeout: 0.1)
        // Then Triggering Search calls changeSelectedScope
        XCTAssertEqual(view.changeSelectedScopeCallCount, 1)
    }

    func testThatCallingNavigateToSearchDeepLinkForMediaTriggersSearch() {
        // Given
        let url = URL(string: "https://next.amboss.com/de/search?q=diabetes&v=media")!
        let searchDeeplink = SearchDeeplink(url: url)!
        presenter.view = view

        let searchOverviewResult: SearchOverviewResult = .fixture()
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        let expectation = self.expectation(description: "overviewSearch is called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            expectation.fulfill()
        }

        // When
        presenter.navigate(to: searchDeeplink)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatCallingNavigateToSearchDeepLinkForMediaUpdatesSelectedScope() {
        // Given
        let url = URL(string: "https://next.amboss.com/de/search?q=diabetes&v=media")!
        let searchDeeplink = SearchDeeplink(url: url)!
        presenter.view = view

        let searchOverviewResult: SearchOverviewResult = .fixture(mediaItems: [.fixture()], mediaItemsTotalCount: 1, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(searchOverviewResult: searchOverviewResult)

        let expectation = self.expectation(description: "overviewSearch is called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            expectation.fulfill()
        }

        // Call count before navigating to search deeplink
        XCTAssertEqual(view.changeSelectedScopeCallCount, 0)

        // When
        presenter.navigate(to: searchDeeplink)

        wait(for: [expectation], timeout: 0.1)
        // Then Triggering Search calls changeSelectedScope
        XCTAssertEqual(view.changeSelectedScopeCallCount, 1)
    }

    func testThatCallingNavigateToSearchDeepLinkForPharmaDoesntTriggersSearchIfDiscalimerIsNotAccepted() {
        // Given
        let url = URL(string: "https://next.amboss.com/de/search?q=ramipril&v=pharma")!
        let searchDeeplink = SearchDeeplink(url: url)!
        userDataRepository.hasConfirmedHealthCareProfession = false
        presenter.view = view
        // Call count before navigating to search deeplink
        XCTAssertEqual(view.changeSelectedScopeCallCount, 0)

        // When
        presenter.navigate(to: searchDeeplink)

        // Then Triggering Search doesn't call changeSelectedScope
        XCTAssertEqual(view.changeSelectedScopeCallCount, 0)
    }

    func testThatCallingDismissViewCallsTheCoordinator() {
        presenter.dismissView(query: .fixture())

        XCTAssertEqual(searchCoordinator.stopCallCount, 1)
    }

    func testShouldShowDisclaimerIfUserHasNotAcceptedYetAndScopeShouldNotChangeToPharmaIfUserDidNotAcceptAgain() {

        userDataRepository.hasConfirmedHealthCareProfession = false

        presenter.view = view
        view.showDisclaimerDialogHandler = { callback in
            callback(false)
        }

        userDataClient.setHealthcareProfessionHandler = { didAccept, _ in
            XCTAssertFalse(didAccept)
        }
        
        let pharmaScope = SearchScope.pharma(itemCount: 0)
        
        view.showSectionsHandler = { _, _, scope in
            XCTAssertNotEqual(scope, pharmaScope)
        }
        
        presenter.didTapScope(pharmaScope, query: .fixture())
        
    }

    func testShouldShowDisclaimerIfUserHasNotAcceptedYetAndScopeShouldChangeToPharmaIfUserDidAccept() {
        let expectation = self.expectation(description: "Scope should not change")

        userDataRepository.hasConfirmedHealthCareProfession = false

        presenter.view = view
        view.showDisclaimerDialogHandler = { callback in
            callback(true)
        }

        userDataClient.setHealthcareProfessionHandler = { didAccept, _ in
            XCTAssertTrue(didAccept)
        }
        let pharmaScope = SearchScope.pharma(itemCount: 0)
        view.showSectionsHandler = { _, _, scope in
            
            XCTAssertEqual(scope, pharmaScope)
            expectation.fulfill()
            XCTAssertTrue(self.userDataRepository.hasConfirmedHealthCareProfession!)
        }
        presenter.didTapScope(pharmaScope, query: .fixture())

        wait(for: [expectation], timeout: 1)
    }

    func testShouldNotShowDisclaimerIfUserHasAcceptedAlready() {
        let expectation = self.expectation(description: "Scope should not change")

        userDataRepository.hasConfirmedHealthCareProfession = true

        presenter.view = view

        view.showDisclaimerDialogHandler = { callback in
            XCTFail("Disclaimer should not show when user hasConfirmedHealthCareProfession is true")
        }
        
        let pharmaScope = SearchScope.pharma(itemCount: 0)
        
        view.showSectionsHandler = { _, _, scope in
            XCTAssertEqual(scope, pharmaScope)
            expectation.fulfill()
        }
        
        presenter.didTapScope(pharmaScope, query: .fixture())
        wait(for: [expectation], timeout: 1)
    }

    func testThatWhenPharmaInstantResultIsSelectedThenTheCoordinatorCallsNavigateToAgent() {

        presenter.view = view

        let searchItem = SearchResultItemViewData.instantResult(suggestedTerm: InstantResultViewItem(attributedText: .fixture(), value: .fixture(), type: .pharmaCard(.fixture(), trackingData: .fixture())), query: .fixture())

        presenter.didSelect(searchItem: searchItem, at: 0, subIndex: nil)
        XCTAssertEqual(searchCoordinator.navigateToDrugCallCount, 1)

    }

    func testThatWhenMonographInstantResultIsSelectedThenTheCoordinatorCallsNavigateToMonograph() {

        presenter.view = view

        let searchItem = SearchResultItemViewData.instantResult(suggestedTerm: InstantResultViewItem(attributedText: .fixture(), value: .fixture(), type: .monograph(.fixture(), trackingData: .fixture())), query: .fixture())

        presenter.didSelect(searchItem: searchItem, at: 0, subIndex: nil)
        XCTAssertEqual(searchCoordinator.navigateToMonographDeeplinkCallCount, 1)

    }

    func testThatWhenArticleInstantResultIsSelectedThenTheCoordinatorCallsNavigateToLearningCard() {
        presenter.view = view

        let searchItem = SearchResultItemViewData.instantResult(suggestedTerm: InstantResultViewItem(attributedText: .fixture(), value: .fixture(), type: .article(.fixture(), trackingData: .fixture())), query: .fixture())

        presenter.didSelect(searchItem: searchItem, at: 0, subIndex: nil)
        XCTAssertEqual(searchCoordinator.navigateToLearningCardDeeplinkCallCount, 1)
    }

    func testThatRefocusingSearchBarTextFieldTriggersSuggestionsSearch() {
        let currentSearchBarTextFieldText: String = .fixture()
        let expectation = self.expectation(description: "fetch suggestions was called on suggestions repository")
        suggestionRepository.suggestionsHandler = { query, completion in
            XCTAssertEqual(currentSearchBarTextFieldText, query)
            completion(.fixture())
            expectation.fulfill()
        }

        presenter.searchBarTextFieldTapped(text: currentSearchBarTextFieldText)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingNoResultsViewContactUsButtonCallsCoordinatorWithTheFormUrl() {
        appConfiguration.searchNoResultsFeedbackForm = .fixture()
        let expectation = self.expectation(description: "openURLCallCount was called on search coordinator")
        searchCoordinator.openURLInternallyHandler = { url in
            XCTAssertEqual(self.appConfiguration.searchNoResultsFeedbackForm, url)
            expectation.fulfill()
        }

        presenter.contactUsButtonTapped()

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenViewIsSetTheViewIsUpdatedWithTheUserActivityForSearch() {
        let ambossShortcutUserActivity = NSUserActivity(activityType: .fixture())
        shortcutsService.userActivityHandler = { ambossShortcut in
            switch ambossShortcut {
            case .search: return ambossShortcutUserActivity
            }
        }
        let expectation = self.expectation(description: "view was updated with user activity")
        view.setUserActivityHandler = { userActivity in
            XCTAssertEqual(userActivity, ambossShortcutUserActivity)
            expectation.fulfill()
        }

        presenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenViewIsSetTheShortcutsRepositoryIsUpdated() {
        let expectation = self.expectation(description: "shortcutsRepository was updated")
        shortcutsRepository.increaseUsageCountHandler = { ambossShortcut in
            XCTAssertEqual(ambossShortcut, .search)
            expectation.fulfill()
        }

        presenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenViewIsSetUserIsOfferedTheOptionToAddVoiceShortcutForSearchIfTheOfferWasEligible() {
        shortcutsRepository.shouldOfferAddingVoiceShortcutHandler = { _ in
            true
        }
        XCTAssertEqual(view.presentMessageCallCount, 0)

        presenter.view = view

        XCTAssertEqual(view.presentMessageCallCount, 1)
    }

    func testThatSiriMessageHasAButtonToAcceptAndAButtonToReject() {
        shortcutsRepository.shouldOfferAddingVoiceShortcutHandler = { _ in
            true
        }
        let expectation = self.expectation(description: "view was updated")
        view.presentMessageHandler = { _, actions in
            XCTAssertEqual(actions.count, 2)
            XCTAssertEqual(actions[0].title, L10n.Shortcuts.Search.AddToSiriAlert.no)
            XCTAssertEqual(actions[1].title, L10n.Shortcuts.Search.AddToSiriAlert.addToSiriButtonTitle)
            expectation.fulfill()
        }

        presenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingOnNotNowDoesNotCallTheCoordinator() {
        shortcutsRepository.shouldOfferAddingVoiceShortcutHandler = { _ in
            true
        }
        let expectation = self.expectation(description: "view was updated")
        view.presentMessageHandler = { _, actions in
            XCTAssertEqual(self.searchCoordinator.navigateToAddVoiceSearchShortcutCallCount, 0)
            actions[0].execute()
            XCTAssertEqual(self.searchCoordinator.navigateToAddVoiceSearchShortcutCallCount, 0)
            expectation.fulfill()
        }

        presenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingOnNotNowUpdatesTheShortcutsRepository() {
        shortcutsRepository.shouldOfferAddingVoiceShortcutHandler = { _ in
            true
        }
        let expectation = self.expectation(description: "view was updated")
        view.presentMessageHandler = { _, actions in
            XCTAssertEqual(self.shortcutsRepository.addingVoiceShortcutWasOfferedCallCount, 0)
            actions[0].execute()
            XCTAssertEqual(self.shortcutsRepository.addingVoiceShortcutWasOfferedCallCount, 1)
            expectation.fulfill()
        }

        presenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTappingOnAddToSiriCallsTheRightMethodOnCoordinator() {
        shortcutsRepository.shouldOfferAddingVoiceShortcutHandler = { _ in
            true
        }
        let expectation = self.expectation(description: "view was updated")
        view.presentMessageHandler = { _, actions in
            XCTAssertEqual(self.searchCoordinator.navigateToAddVoiceSearchShortcutCallCount, 0)
            actions[1].execute()
            XCTAssertEqual(self.searchCoordinator.navigateToAddVoiceSearchShortcutCallCount, 1)
            expectation.fulfill()
        }

        presenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTrackingEventIsTrigerredWhenSiriShortcutDialogShown() {
        shortcutsRepository.shouldOfferAddingVoiceShortcutHandler = { _ in
            true
        }
        let exp = expectation(description: "presentMessage function was called")
        view.presentMessageHandler = { _, _ in
            exp.fulfill()
        }
        let trackingExpectation = expectation(description: "Tracking  was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .siri(let event):
                switch event {
                case .searchSiriShortcutDialogShown:
                    trackingExpectation.fulfill()
                default: break
                }
            default: break
            }
        }

        presenter.view = view

        wait(for: [exp, trackingExpectation], timeout: 0.1)
    }

    func testThatTrackingEventIsTrigerredWhenSearchSiriShortcutDialogAccepted() {
        shortcutsRepository.shouldOfferAddingVoiceShortcutHandler = { _ in
            true
        }
        let exp = expectation(description: "presentMessage function was called")
        view.presentMessageHandler = { _, actions in
            actions[1].execute()
            exp.fulfill()
        }
        let trackingExpectation = expectation(description: "Tracking  was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .siri(let event):
                switch event {
                case .searchSiriShortcutDialogAccepted:
                    trackingExpectation.fulfill()
                default: break
                }
            default: break
            }
        }

            presenter.view = view

            wait(for: [exp, trackingExpectation], timeout: 0.1)
        }

    func testThatTrackingEventIsTrigerredWhenSearchSiriShortcutDialogDeclined() {
        shortcutsRepository.shouldOfferAddingVoiceShortcutHandler = { _ in
            true
        }
        let exp = expectation(description: "presentMessage function was called")
        view.presentMessageHandler = { _, actions in
            actions[0].execute()
            exp.fulfill()
        }
        let trackingExpectation = expectation(description: "Tracking  was called")
        trackingProvider.trackHandler = { event in
            switch event {
            case .siri(let event):
                switch event {
                case .searchSiriShortcutDialogDeclined:
                    trackingExpectation.fulfill()
                default: break
                }
            default: break
            }
        }

            presenter.view = view

            wait(for: [exp, trackingExpectation], timeout: 0.1)
        }

    func testThatWhenViewIsSetUserIsNotOfferedTheOptionToAddVoiceShortcutForSearchIfTheOfferWasIneligible() {
        shortcutsRepository.shouldOfferAddingVoiceShortcutHandler = { _ in
            false
        }
        XCTAssertEqual(view.presentMessageCallCount, 0)

        presenter.view = view

        XCTAssertEqual(view.presentMessageCallCount, 0)
    }

    func testThatWhenANewSearchIsStartedThenMediaCacheIsCleaned() {
        XCTAssertEqual(mediaRepository.clearCacheCallCount, 0)

        presenter.searchBarSearchButtonTapped(query: .fixture())

        XCTAssertEqual(mediaRepository.clearCacheCallCount, 1)
    }

    func testThatScrollingToTheBottomOnArticleTabCallsRepositoryToFetchMoreArticleItemsIfArticlesHasNextPage() {
        let searchOverviewResult: SearchOverviewResult = .fixture(articlePageInfo: .some(.fixture(endCursor: "fixture_endCursor", hasNextPage: true)), targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        let overviewSearchExpectation = self.expectation(description: "overview search was called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            overviewSearchExpectation.fulfill()
        }
        presenter.searchBarSearchButtonTapped(query: .fixture())

        let fetchMoreExpectation = self.expectation(description: "fetch article page was called")
        searchRepository.fetchArticleSearchResultPageHandler = { _, _, _, cursor, _ in
            XCTAssertEqual(cursor, searchOverviewResult.articlePageInfo?.endCursor)
            fetchMoreExpectation.fulfill()
        }

        presenter.didScrollToBottom(with: .library(itemCount: .fixture()))

        wait(for: [overviewSearchExpectation, fetchMoreExpectation], timeout: 0.2)
    }

    func testThatScrollingToTheBottomOnArticleTabDoesNotCallRepositoryToFetchMoreArticleItemsIfArticlesDoesNotHaveNextPage() {
        let searchOverviewResult: SearchOverviewResult = .fixture(articlePageInfo: .some(.fixture(endCursor: "fixture_endCursor", hasNextPage: false)), targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        let overviewSearchExpectation = self.expectation(description: "overview search was called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            overviewSearchExpectation.fulfill()
        }
        presenter.searchBarSearchButtonTapped(query: .fixture())

        XCTAssertEqual(searchRepository.fetchArticleSearchResultPageCallCount, 0)
        presenter.didScrollToBottom(with: .library(itemCount: .fixture()))
        XCTAssertEqual(searchRepository.fetchArticleSearchResultPageCallCount, 0)

        wait(for: [overviewSearchExpectation], timeout: 0.2)
    }

    func testThatScrollingToTheBottomOnArticleTabWhenOfflieDoesNotCallRepositoryToFetchMoreArticleItems() {
        let expectedSearchResults = SearchResult.fixture(resultType: .offline(duration: .fixture()), searchOverviewResult: .fixture())

        let overviewSearchExpectation = self.expectation(description: "overview search was called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            overviewSearchExpectation.fulfill()
        }
        presenter.searchBarSearchButtonTapped(query: .fixture())

        XCTAssertEqual(searchRepository.fetchArticleSearchResultPageCallCount, 0)
        presenter.didScrollToBottom(with: .library(itemCount: .fixture()))
        XCTAssertEqual(searchRepository.fetchArticleSearchResultPageCallCount, 0)

        wait(for: [overviewSearchExpectation], timeout: 0.2)
    }

    func testThatScrollingToTheBottomOnPharmaTabCallsRepositoryToFetchMorePharmaItemsIfPharmaHasNextPage() {
        appConfiguration.appVariant = .wissen
        let searchOverviewResult: SearchOverviewResult = .fixture(pharmaInfo: .pharmaCard(pharmaItems: .fixture(), pharmaItemsTotalCount: .fixture(), pageInfo: .some(.fixture(endCursor: "fixture_endCursor", hasNextPage: true))), targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        let overviewSearchExpectation = self.expectation(description: "overview search was called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            overviewSearchExpectation.fulfill()
        }
        presenter.searchBarSearchButtonTapped(query: .fixture())

        let fetchMoreExpectation = self.expectation(description: "fetch pharma page was called")
        searchRepository.fetchPharmaSearchResultPageHandler = { _, _, _, cursor, _ in
            switch searchOverviewResult.pharmaInfo {
            case .pharmaCard(_, _, let pageInfo):
                XCTAssertEqual(cursor, pageInfo?.endCursor)
            default:
                XCTFail()
            }

            fetchMoreExpectation.fulfill()
        }

        presenter.didScrollToBottom(with: .pharma(itemCount: .fixture()))

        wait(for: [overviewSearchExpectation, fetchMoreExpectation], timeout: 0.2)
    }

    func testThatScrollingToTheBottomOnPharmaTabDoesNotCallRepositoryToFetchMorePharmaItemsIfPharmaDoesNotHaveNextPage() {
        appConfiguration.appVariant = .wissen
        let searchOverviewResult: SearchOverviewResult = .fixture(pharmaInfo: .pharmaCard(pharmaItems: .fixture(), pharmaItemsTotalCount: .fixture(), pageInfo: .some(.fixture(endCursor: "fixture_endCursor", hasNextPage: false))), targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        let overviewSearchExpectation = self.expectation(description: "overview search was called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            overviewSearchExpectation.fulfill()
        }
        presenter.searchBarSearchButtonTapped(query: .fixture())

        XCTAssertEqual(searchRepository.fetchPharmaSearchResultPageCallCount, 0)
        presenter.didScrollToBottom(with: .pharma(itemCount: .fixture()))
        XCTAssertEqual(searchRepository.fetchPharmaSearchResultPageCallCount, 0)

        wait(for: [overviewSearchExpectation], timeout: 0.2)
    }

    func testThatScrollingToTheBottomOnPharmaTabWhenOfflieDoesNotCallRepositoryToFetchMoreArticleItems() {
        let expectedSearchResults = SearchResult.fixture(resultType: .offline(duration: .fixture()), searchOverviewResult: .fixture())

        let overviewSearchExpectation = self.expectation(description: "overview search was called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            overviewSearchExpectation.fulfill()
        }
        presenter.searchBarSearchButtonTapped(query: .fixture())

        XCTAssertEqual(searchRepository.fetchArticleSearchResultPageCallCount, 0)
        presenter.didScrollToBottom(with: .pharma(itemCount: .fixture()))
        XCTAssertEqual(searchRepository.fetchArticleSearchResultPageCallCount, 0)

        wait(for: [overviewSearchExpectation], timeout: 0.2)
    }

    func testThatScrollingToTheBottomOnGuidelineTabCallsRepositoryToFetchMoreGuidelineItemsIfGuidelinesHasNextPage() {
        let searchOverviewResult: SearchOverviewResult = .fixture(guidelinePageInfo: .some(.fixture(endCursor: "fixture_endCursor", hasNextPage: true)), targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        let overviewSearchExpectation = self.expectation(description: "overview search was called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            overviewSearchExpectation.fulfill()
        }
        presenter.searchBarSearchButtonTapped(query: .fixture())

        let fetchMoreExpectation = self.expectation(description: "fetch guideline page was called")
        searchRepository.fetchGuidelineSearchResultPageHandler = { _, _, _, cursor, _ in
            XCTAssertEqual(cursor, searchOverviewResult.guidelinePageInfo?.endCursor)
            fetchMoreExpectation.fulfill()
        }

        presenter.didScrollToBottom(with: .guideline(itemCount: .fixture()))

        wait(for: [overviewSearchExpectation, fetchMoreExpectation], timeout: 0.2)
    }

    func testThatScrollingToTheBottomOnGuidelineTabDoesNotCallRepositoryToFetchMoreGuidelineItemsIfGuidelinesDoesNotHaveNextPage() {
        let searchOverviewResult: SearchOverviewResult = .fixture(guidelinePageInfo: .some(.fixture(endCursor: "fixture_endCursor", hasNextPage: false)), targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        let overviewSearchExpectation = self.expectation(description: "overview search was called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            overviewSearchExpectation.fulfill()
        }
        presenter.searchBarSearchButtonTapped(query: .fixture())

        XCTAssertEqual(searchRepository.fetchGuidelineSearchResultPageCallCount, 0)
        presenter.didScrollToBottom(with: .guideline(itemCount: .fixture()))
        XCTAssertEqual(searchRepository.fetchGuidelineSearchResultPageCallCount, 0)

        wait(for: [overviewSearchExpectation], timeout: 0.2)
    }

    func testThatScrollingToTheBottomOnGuidelineTabWhenOfflieDoesNotCallRepositoryToFetchMoreArticleItems() {
        let expectedSearchResults = SearchResult.fixture(resultType: .offline(duration: .fixture()), searchOverviewResult: .fixture())

        let overviewSearchExpectation = self.expectation(description: "overview search was called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            overviewSearchExpectation.fulfill()
        }
        presenter.searchBarSearchButtonTapped(query: .fixture())

        XCTAssertEqual(searchRepository.fetchArticleSearchResultPageCallCount, 0)
        presenter.didScrollToBottom(with: .guideline(itemCount: .fixture()))
        XCTAssertEqual(searchRepository.fetchArticleSearchResultPageCallCount, 0)

        wait(for: [overviewSearchExpectation], timeout: 0.2)
    }

    func testThatScrollingToTheBottomOnMediaTabCallsRepositoryToFetchMoreMediaItemsIfMediaHasNextPage() {
        let searchOverviewResult: SearchOverviewResult = .fixture(mediaPageInfo: .some(.fixture(endCursor: "fixture_endCursor", hasNextPage: true)), targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        let overviewSearchExpectation = self.expectation(description: "overview search was called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            overviewSearchExpectation.fulfill()
        }
        presenter.searchBarSearchButtonTapped(query: .fixture())

        let fetchMoreExpectation = self.expectation(description: "fetch guideline page was called")
        searchRepository.fetchMediaSearchResultPageHandler = { _, _, _, _, cursor, _ in
            XCTAssertEqual(cursor, searchOverviewResult.mediaPageInfo?.endCursor)
            fetchMoreExpectation.fulfill()
        }

        presenter.didScrollToBottom(with: .media(itemCount: .fixture()))

        wait(for: [overviewSearchExpectation, fetchMoreExpectation], timeout: 0.2)
    }

    func testThatScrollingToTheBottomOnMediaTabDoesNotCallRepositoryToFetchMoreMediaItemsIfMediaDoesNotHaveNextPage() {
        let searchOverviewResult: SearchOverviewResult = .fixture(mediaPageInfo: .some(.fixture(endCursor: "fixture_endCursor", hasNextPage: false)), targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        let overviewSearchExpectation = self.expectation(description: "overview search was called")
        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
            overviewSearchExpectation.fulfill()
        }
        presenter.searchBarSearchButtonTapped(query: .fixture())

        XCTAssertEqual(searchRepository.fetchMediaSearchResultPageCallCount, 0)
        presenter.didScrollToBottom(with: .media(itemCount: .fixture()))
        XCTAssertEqual(searchRepository.fetchMediaSearchResultPageCallCount, 0)

        wait(for: [overviewSearchExpectation], timeout: 0.2)
    }

    func testThatShowingADidYouMeanSearchResultCallsSearchFollowupQueriesShownTrackingEvent() {
        let searchTerm: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        let correctedSearchTerm = String.fixture()
        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: nil, articleItems: [.fixture()], articleItemsTotalCount: 1, mediaItems: [], mediaItemsTotalCount: 0, correctedSearchTerm: correctedSearchTerm, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        trackingProvider.trackHandler = { event in
            print(event)
            switch event {
            case .search(let event):
                switch event {
                case .searchFollowupQueriesShown(let followupQuery, _, let searchSessionQuery, let searchSessionDYM),
                     .searchFollowupQuerySelected(let followupQuery, _, let searchSessionQuery, let searchSessionDYM):
                    // Cant test searchSessionID cause its privately generated by the presenter
                    XCTAssertEqual(followupQuery, "\"\(searchTerm)\"")
                    XCTAssertEqual(searchTerm, searchSessionQuery)
                    XCTAssertEqual(searchSessionDYM, correctedSearchTerm)
                    expectation.fulfill()
                default:
                    break
                }
            default: XCTFail("Unexpected event")
            }
        }

        presenter.searchBarSearchButtonTapped(query: searchTerm) // -> searchFollowupQueriesShown
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatSelectingADidYouMeanSearchResultCallsSearchFollowupQueriesSelectedTrackingEvent() {
        let searchTerm: String = .fixture()
        let expectation = self.expectation(description: "tracking event was called")

        let correctedSearchTerm = String.fixture()
        let searchOverviewResult: SearchOverviewResult = .fixture(phrasionary: nil, articleItems: [.fixture()], articleItemsTotalCount: 1, mediaItems: [], mediaItemsTotalCount: 0, correctedSearchTerm: correctedSearchTerm, targetScope: nil)
        let expectedSearchResults = SearchResult.fixture(resultType: .online(duration: .fixture()), searchOverviewResult: searchOverviewResult)

        searchRepository.overviewSearchHandler = { _, _, completion in
            completion(.success(expectedSearchResults))
        }

        trackingProvider.trackHandler = { event in
            print(event)
            switch event {
            case .search(let event):
                switch event {
                case .searchFollowupQuerySelected(let followupQuery, _, let searchSessionQuery, let searchSessionDYM):
                    // Cant test searchSessionID cause its privately generated by the presenter
                    XCTAssertEqual(followupQuery, "\"\(searchTerm)\"")
                    XCTAssertEqual(searchTerm, searchSessionQuery)
                    XCTAssertEqual(searchSessionDYM, correctedSearchTerm)
                    expectation.fulfill()
                default:
                    break
                }
            default: XCTFail("Unexpected event")
            }
        }

        presenter.searchBarSearchButtonTapped(query: searchTerm) // -> searchFollowupQueriesShown
        presenter.didYouMeanResultTapped(searchTerm: searchTerm, didYouMean: correctedSearchTerm) // -> searchFollowupQuerySelected
        wait(for: [expectation], timeout: 0.1)
    }
}

private extension SearchPresenterTests {
    func expectedOverviewSectionsCount(for searchOverviewResult: SearchOverviewResult) -> Int {
        var expectedSectionsCount = 0

        if searchOverviewResult.phrasionary != nil {
            expectedSectionsCount += 1
        }

        if !searchOverviewResult.articleItems.isEmpty {
            expectedSectionsCount += 1
        }

        if !searchOverviewResult.guidelineItems.isEmpty {
            expectedSectionsCount += 1
        }

        if !searchOverviewResult.mediaItems.isEmpty {
            expectedSectionsCount += 1
        }

        switch searchOverviewResult.pharmaInfo {
        case .pharmaCard(let pharmaItems, _, _):
            if !pharmaItems.isEmpty {
                expectedSectionsCount += 1
            }
        case .monograph(let monographItems, _, _):
            if !monographItems.isEmpty {
                expectedSectionsCount += 1
            }
        default: break
        }

        return expectedSectionsCount
    }

    func verifyOverviewScopeContent(_ sections: [SearchResultSection], for searchOverviewResult: SearchOverviewResult) {
        var index = 0

        if searchOverviewResult.phrasionary != nil {
            verifyPhrasionarySection(sections[index], for: searchOverviewResult)
            index = index + 1
        }

        if !searchOverviewResult.articleItems.isEmpty {
            verifyArticleSection(sections[index], for: searchOverviewResult)
            index = index + 1
        }

        if searchOverviewResult.pharmaInfo?.isEmpty == false {
            verifyPharmaSection(sections[index], for: searchOverviewResult)
            index = index + 1
        }

        if !searchOverviewResult.guidelineItems.isEmpty {
            verifyGuidelineSection(sections[index], for: searchOverviewResult)
            index = index + 1
        }

        if !searchOverviewResult.mediaItems.isEmpty {
            verifyMediaSection(sections[index], for: searchOverviewResult)
            index = index + 1
        }
    }

    func verifyMediaSection(_ section: SearchResultSection, for searchOverviewResult: SearchOverviewResult) {
        if case let .mediaOverview(mediaSearchOverviewItems: items, _) = section.items.first {
            let maxNumberOfMediaItemsInOverView = 5
            let mediaItems = Array(items.prefix(maxNumberOfMediaItemsInOverView))
            for (i, item) in mediaItems.enumerated() {
                switch item {
                case .mediaViewItem(let mediaItem):
                    XCTAssertEqual(searchOverviewResult.mediaItems[i].title, mediaItem.title)
                    XCTAssertEqual(searchOverviewResult.mediaItems[i].externalAddition?.type, mediaItem.externalAdditionType)
                    XCTAssertEqual(searchOverviewResult.mediaItems[i].mediaId, mediaItem.mediaId)
                case .viewMoreItem: break
                }
            }
        }
    }

    func verifyPhrasionarySection(_ section: SearchResultSection, for searchOverviewResult: SearchOverviewResult) {
        if case let .phrasionary(phrasionaryViewItem) = section.items[0] {
            XCTAssertEqual(phrasionaryViewItem.title, searchOverviewResult.phrasionary?.title)
            XCTAssertEqual(phrasionaryViewItem.body, searchOverviewResult.phrasionary?.body)
            XCTAssertEqual(phrasionaryViewItem.subtitle1, searchOverviewResult.phrasionary?.synonyms.joined(separator: ", "))
            XCTAssertEqual(phrasionaryViewItem.subtitle2, searchOverviewResult.phrasionary?.etymology)
            XCTAssertEqual(phrasionaryViewItem.targets.count, searchOverviewResult.phrasionary?.targets.count)
        }
    }

    func verifyArticleSection(_ section: SearchResultSection, for searchOverviewResult: SearchOverviewResult) {
        for (index, item) in section.items.enumerated() {
            if case let .article(articleSearchViewItem, _) = item {
                XCTAssertEqual(searchOverviewResult.articleItems[index].title, articleSearchViewItem.title?.string ?? "")
                XCTAssertEqual(searchOverviewResult.articleItems[index].body, articleSearchViewItem.body?.string ?? "")
                XCTAssertEqual(searchOverviewResult.articleItems[index].deepLink, articleSearchViewItem.deeplink)
            }
        }
    }

    func verifyPharmaSection(_ section: SearchResultSection, for searchOverviewResult: SearchOverviewResult) {
        for (index, item) in section.items.enumerated() {
            if case let .pharma(pharmaSearchViewItem, _, _) = item, case let .pharmaCard(pharmaItems, _, _) = searchOverviewResult.pharmaInfo {
                XCTAssertEqual(pharmaSearchViewItem.substanceID, pharmaItems[index].substanceID)
                XCTAssertEqual(pharmaSearchViewItem.drugId, pharmaItems[index].drugid)
                XCTAssertEqual(pharmaSearchViewItem.title, pharmaItems[index].title)

                let details = (pharmaItems[index].details ?? []).reduce(into: String()) { result, string in result.append("<br>\(string)") }
                XCTAssertEqual(pharmaSearchViewItem.details, details)
            } else if case let .monograph(monographSearchViewItem, _) = item, case let .monograph(monographItems, _, _) = searchOverviewResult.pharmaInfo {
                XCTAssertEqual(monographSearchViewItem.title?.string ?? "", monographItems[index].title)
                XCTAssertEqual(monographSearchViewItem.deeplink, monographItems[index].deepLink)
            }
        }
    }

    func verifyGuidelineSection(_ section: SearchResultSection, for searchOverviewResult: SearchOverviewResult) {
        for (index, item) in section.items.enumerated() {
            if case let .guideline(guidelineSearchViewItem, _) = item {
                let guidelineItem = searchOverviewResult.guidelineItems[index]
                XCTAssertEqual(guidelineItem.title, guidelineSearchViewItem.title)
                XCTAssertEqual(URL(string: guidelineItem.externalURL!)!, guidelineSearchViewItem.externalURL)
                XCTAssertEqual(guidelineItem.tags?.first, guidelineSearchViewItem.tag)

                let details = (guidelineItem.details ?? []).reduce(into: String()) { result, string in result.append("<br>\(string)") }
                XCTAssertEqual(details, guidelineSearchViewItem.details)
            }
        }
    }
}

extension SearchScope: Equatable {
    public static func == (lhs: SearchScope, rhs: SearchScope) -> Bool {
        switch (lhs, rhs) {
        case (.overview, .overview): return true
        case (.library(let lhsArticleCount), .library(let rhsArticleCount)): return lhsArticleCount == rhsArticleCount
        case (.pharma(let lhsPharmaCount), .pharma(let rhsPharmaCount)): return lhsPharmaCount == rhsPharmaCount
        case (.media(let lhsMediaCount), .media(let rhsMediaCount)): return lhsMediaCount == rhsMediaCount
        default: return false
        }
    }
}

extension SearchOverviewResult.PharmaInfo {
    var isEmpty: Bool {
        switch self {
        case .pharmaCard(let pharmaItems, _, _): return pharmaItems.isEmpty
        case .monograph(let monographItems, _, _): return monographItems.isEmpty
        }
    }
}
