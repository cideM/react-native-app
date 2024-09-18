//
//  InArticleSearchPresenterTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 20.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
@testable import Knowledge_DE
import XCTest

class InArticleSearchPresenterTests: XCTestCase {

    var presenter: InArticleSearchPresenterType!
    var view: InArticleSearchViewTypeMock!
    var searchDelay = 0.0
    var learningCardTracker: LearningCardTrackerTypeMock!
    var trackingProvider: TrackingTypeMock!

    override func setUp() {
        view = InArticleSearchViewTypeMock()
        trackingProvider = TrackingTypeMock()
        learningCardTracker = LearningCardTrackerTypeMock()
        learningCardTracker.trackingProvider = trackingProvider
        presenter = InArticleSearchPresenter(learningCardTracker: learningCardTracker)
        presenter.view = view
    }

    func testThatWhenTheSearchTextChangesInTheViewThePresenterSearchesForTheNewText() {
        presenter = InArticleSearchPresenter(learningCardTracker: learningCardTracker)
        presenter.view = view
        let exp = expectation(description: "Search was called on the view")
        view.startSearchHandler = { _, _ in
            exp.fulfill()
        }

        presenter.searchTextDidChange("quer")

        wait(for: [exp], timeout: 1.0)
    }

    func testThatWhenTheSearchTextChangesInTheViewAFindInPageTrackingEventIsSent() {
        presenter = InArticleSearchPresenter(learningCardTracker: learningCardTracker)
        presenter.view = view

        let searchText = String.fixture()
        let results = Array(repeating: InArticleResultIndentifier.fixture(), count: .random(in: 10...99))
        let exp = expectation(description: "Tracking event was sent")

        learningCardTracker.trackArticleFindInPageEditedHandler = { query, count, index in
            XCTAssertEqual(searchText, query)
            XCTAssertEqual(count, results.count)
            XCTAssertEqual(index, 0)
            exp.fulfill()
        }

        view.startSearchHandler = { _, completion in
            let response = InArticleSearchResponse(identifier: .fixture(), results: results)
            completion(.success(response))
        }

        presenter.searchTextDidChange(searchText)
        wait(for: [exp], timeout: 1.0)
    }

    func testThatWhenTheNextInPageSearchResultIsSelectedAFindInPageTrackingEventIsSent() {
        presenter = InArticleSearchPresenter(learningCardTracker: learningCardTracker)
        presenter.view = view

        let searchText = String.fixture()
        let count = Int.random(in: 10...99)
        let results = Array(repeating: InArticleResultIndentifier.fixture(), count: count)

        let initExpectation = expectation(description: "Search query was set")
        let nextResultExpectation = expectation(description: "Next search result was selected")
        nextResultExpectation.expectedFulfillmentCount = count - 1

        var currentIndex = 0
        learningCardTracker.trackArticleFindInPageEditedHandler = { _, resultCount, index in
            XCTAssertEqual(resultCount, count)
            if currentIndex == 0 {
                initExpectation.fulfill()
            } else {
                XCTAssertEqual(currentIndex, index)
                nextResultExpectation.fulfill()
            }
            currentIndex += 1
        }

        view.startSearchHandler = { _, completion in
            let response = InArticleSearchResponse(identifier: .fixture(), results: results)
            completion(.success(response))
        }

        presenter.searchTextDidChange(searchText) // <- required to init private var "searchRepository"
        wait(for: [initExpectation], timeout: 1.0)

        for _ in 0..<(count - 1) {
            presenter.goToNextSearchResult()
        }
        wait(for: [nextResultExpectation], timeout: 1.0)
    }

    func testThatWhenThePreviousInPageSearchResultIsSelectedAFindInPageTrackingEventIsSent() {
        presenter = InArticleSearchPresenter(learningCardTracker: learningCardTracker)
        presenter.view = view

        let searchText = String.fixture()
        let count = Int.random(in: 10...99)
        let results = Array(repeating: InArticleResultIndentifier.fixture(), count: count)

        let initExpectation = expectation(description: "Search query was set")
        let previousExpectation = expectation(description: "Next search result was selected")
        previousExpectation.expectedFulfillmentCount = count - 1

        var currentIndex: Int?
        learningCardTracker.trackArticleFindInPageEditedHandler = { _, resultCount, index in
            XCTAssertEqual(resultCount, count)
            if currentIndex == nil {
                initExpectation.fulfill()
                currentIndex = resultCount
            } else {
                XCTAssertEqual(currentIndex, index)
                previousExpectation.fulfill()
            }
            currentIndex! -= 1
        }

        view.startSearchHandler = { _, completion in
            let response = InArticleSearchResponse(identifier: .fixture(), results: results)
            completion(.success(response))
        }

        presenter.searchTextDidChange(searchText) // <- required to init private var "searchRepository"
        wait(for: [initExpectation], timeout: 1.0)

        for _ in 0..<(count - 1) {
            presenter.goToPreviousSearchResult()
        }
        wait(for: [previousExpectation], timeout: 1.0)
    }

    func testThatThePresenterCallsDisposeQueryOnTheViewWhenItsCloseMethodIsCalled() {
        presenter.cancelSearch()

        XCTAssertEqual(view.stopSearchCallCount, 1)
    }

    func testThatThePresenterUpdatesTheViewWithTheCorrectSearchResultsCountLabelWhileSearching() {
        let searchResponse = InArticleSearchResponse.fixture(results: [.fixture(), .fixture(), .fixture()])
        let exp = expectation(description: "Search label text was updated")
        view.startSearchHandler = { _, completion in
            completion(.success(searchResponse))
        }
        view.setSearchLabelTextHandler = { text in
            XCTAssertEqual(text, "\(1)/\(searchResponse.results.count)")
            exp.fulfill()
        }

        presenter.searchTextDidChange(.fixture())

        wait(for: [exp], timeout: 1.0)
    }

    func testThatThePresenterUpdatesTheViewWithTheCorrectStringCountLabelIfSearchResultWasEmpty() {
        let searchResponse = InArticleSearchResponse.fixture(results: [])
        let exp = expectation(description: "Search label text was updated")
        view.startSearchHandler = { _, completion in
            completion(.success(searchResponse))
        }
        view.setSearchLabelTextHandler = { text in
            XCTAssertEqual(text, "0/0")
            exp.fulfill()
        }

        presenter.searchTextDidChange(.fixture())

        wait(for: [exp], timeout: 1.0)
    }

    func testThatCallingNextSearchResultOnThePresenterCallsScrollToSearchResultOnTheView() {
        let searchResponse = InArticleSearchResponse.fixture(results: [.fixture(), .fixture(), .fixture()])
        let exp = expectation(description: "Search was executed")
        view.startSearchHandler = { _, completion in
            completion(.success(searchResponse))
            exp.fulfill()
        }
        presenter.searchTextDidChange(.fixture())

        wait(for: [exp], timeout: 1.0)
        presenter.goToNextSearchResult()

        XCTAssertEqual(view.goToQueryResultItemCallCount, 1)
    }

    func testThatCallingNextSearchResultOnThePresenterCallsScrollToSearchResultOnTheViewWithTheCorrectNextResult() {
        let searchResponse = InArticleSearchResponse.fixture(results: [.fixture(), .fixture(), .fixture()])
        let exp1 = expectation(description: "Search was executed")
        view.startSearchHandler = { _, completion in
            completion(.success(searchResponse))
            exp1.fulfill()
        }
        let exp2 = expectation(description: "Scroll to query result was executed")
        view.goToQueryResultItemHandler = { result in
            XCTAssertEqual(result, searchResponse.results[1])
            exp2.fulfill()
        }
        presenter.searchTextDidChange(.fixture())
        wait(for: [exp1], timeout: 1.0)
        presenter.goToNextSearchResult()

        wait(for: [exp2], timeout: 1.0)
    }

    func testThatCallingNextSearchResultOnThePresenterWhenTheCurrentSearchResultIsTheLastOneCallsScrollToSearchResultOnTheViewWithTheFirstResult() {
        let searchResponse = InArticleSearchResponse.fixture(results: [.fixture(), .fixture()])
        let exp1 = expectation(description: "Search was executed")
        view.startSearchHandler = { _, completion in
            completion(.success(searchResponse))
            exp1.fulfill()
        }
        presenter.searchTextDidChange(.fixture())
        wait(for: [exp1], timeout: 1.0)
        presenter.goToNextSearchResult()

        let exp2 = expectation(description: "Scroll to query result was executed")
        view.goToQueryResultItemHandler = { result in
            XCTAssertEqual(result, searchResponse.results.first)
            exp2.fulfill()
        }
        presenter.goToNextSearchResult()

        wait(for: [exp2], timeout: 1.0)
    }

    func testThatCallingNextSearchResultOnThePresenterWithEmptySearchResultsDoesNotCallScrollToSearchResultOnTheView() {
        let searchResponse = InArticleSearchResponse.fixture(results: [])
        let exp = expectation(description: "Search was executed")
        view.startSearchHandler = { _, completion in
            completion(.success(searchResponse))
            exp.fulfill()
        }
        presenter.searchTextDidChange(.fixture())

        wait(for: [exp], timeout: 1.0)
        presenter.goToNextSearchResult()

        XCTAssertEqual(view.goToQueryResultItemCallCount, 0)
    }

    func testThatCallingPreviousSearchResultOnThePresenterCallsScrollToSearchResultOnTheView() {
        let searchResponse = InArticleSearchResponse.fixture(results: [.fixture(), .fixture()])
        let exp = expectation(description: "Search was executed")
        view.startSearchHandler = { _, completion in
            completion(.success(searchResponse))
            exp.fulfill()
        }
        presenter.searchTextDidChange(.fixture())

        wait(for: [exp], timeout: 1.0)
        presenter.goToPreviousSearchResult()

        XCTAssertEqual(view.goToQueryResultItemCallCount, 1)
    }

    func testThatCallingPreviousSearchResultOnThePresenterCallsScrollToSearchResultOnTheViewWithTheCorrectPreviousResult() {
        let searchResponse = InArticleSearchResponse.fixture(results: [.fixture(), .fixture()])
        let exp1 = expectation(description: "Search was executed")
        view.startSearchHandler = { _, completion in
            completion(.success(searchResponse))
            exp1.fulfill()
        }
        presenter.searchTextDidChange(.fixture())
        wait(for: [exp1], timeout: 1.0)
        presenter.goToNextSearchResult()

        let exp2 = expectation(description: "Scroll to query result was executed")
        view.goToQueryResultItemHandler = { result in
            XCTAssertEqual(result, searchResponse.results[0])
            exp2.fulfill()
        }
        presenter.goToPreviousSearchResult()

        wait(for: [exp2], timeout: 1.0)
    }

    func testThatCallingPreviousSearchResultOnThePresenterWhenTheCurrentSearchResultIsTheFirstOneCallsScrollToSearchResultOnTheViewWithTheLastResult() {
        let searchResponse = InArticleSearchResponse.fixture(results: [.fixture(), .fixture()])
        let exp1 = expectation(description: "Search was executed")
        view.startSearchHandler = { _, completion in
            completion(.success(searchResponse))
            exp1.fulfill()
        }
        let exp2 = expectation(description: "Scroll to query result was executed")
        view.goToQueryResultItemHandler = { result in
            XCTAssertEqual(result, searchResponse.results.last)
            exp2.fulfill()
        }
        presenter.searchTextDidChange(.fixture())
        wait(for: [exp1], timeout: 1.0)
        presenter.goToPreviousSearchResult()

        wait(for: [exp2], timeout: 1.0)
    }

    func testThatCallingPreviousSearchResultOnThePresenterWithEmptySearchResultsDoesNotCallScrollToSearchResultOnTheView() {
        let searchResponse = InArticleSearchResponse.fixture(results: [])
        let exp = expectation(description: "Search was executed")
        view.startSearchHandler = { _, completion in
            completion(.success(searchResponse))
            exp.fulfill()
        }
        presenter.searchTextDidChange(.fixture())

        wait(for: [exp], timeout: 1.0)
        presenter.goToPreviousSearchResult()

        XCTAssertEqual(view.goToQueryResultItemCallCount, 0)
    }

    func testThatCallingCloseCallsCloseOnTheView() {
        presenter.cancelSearch()

        XCTAssertEqual(view.stopSearchCallCount, 1)
    }
}
