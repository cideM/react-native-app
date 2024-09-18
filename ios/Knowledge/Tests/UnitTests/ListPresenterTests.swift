//
//  ListPresenterTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 27.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
@testable import Knowledge_DE
import XCTest
import Localization

class ListPresenterTests: XCTestCase {

    var presenter: ListPresenterType!
    var coordinator: ListCoordinatorTypeMock!
    var libraryRepository: LibraryRepositoryTypeMock!
    var library: LibraryTypeMock!
    var tagRepository: TagRepositoryTypeMock!
    var trackingProvider: TrackingTypeMock!
    var listTracker: ListTracker!
    var view: ListViewTypeMock!
    var tag: Tag!

    override func setUp() {
        view = ListViewTypeMock()
        coordinator = ListCoordinatorTypeMock()
        library = LibraryTypeMock()
        libraryRepository = LibraryRepositoryTypeMock(library: library, learningCardStack: PointableStack<LearningCardDeeplink>())
        tagRepository = TagRepositoryTypeMock()
        trackingProvider = TrackingTypeMock()
        listTracker = ListTracker(trackingProvider: trackingProvider)
        tag = .fixture()
        presenter = ListPresenter(coordinator: coordinator, tagRepository: tagRepository, libraryRepository: libraryRepository, tag: tag, trackingProvider: listTracker)
    }

    func testThatWhenPresenterViewIsSetThenViewIsInitializedWithItemsThatAreCorrectlyTagged() {

        let favorites = [LearningCardIdentifier.fixture(value: "spec_4"), .fixture(value: "spec_5"), .fixture(value: "spec_6")]
        let opened = [LearningCardIdentifier.fixture(value: "spec_7")]
        let learned = [LearningCardIdentifier.fixture(value: "spec_1"), .fixture(value: "spec_2"), .fixture(value: "spec_3")]

        tagRepository.learningCardsHandler = { tag in
            switch tag {
            case .learned: return learned
            case .favorite: return favorites
            case .opened: return opened
            }
        }

        tagRepository.learningCardsSortedByDateHandler = tagRepository.learningCardsHandler

        library.learningCardMetaItemHandler = { learningCardIdentifier in
            .fixture(title: .fixture(), learningCardIdentifier: learningCardIdentifier)
        }

        view.setTagListViewItemsHandler = { [tag] items in
            let itemIdentifiers = items.map { $0.learningCardMetaItem?.learningCardIdentifier }
            switch tag {
            case .favorite: favorites.forEach { XCTAssert(itemIdentifiers.contains($0), "\($0) is not favorite but should") }
            case .learned: learned.forEach { XCTAssert(itemIdentifiers.contains($0), "\($0) is not learned but should") }
            case .opened: opened.forEach { XCTAssert(itemIdentifiers.contains($0), "\($0) is not opened but should") }
            case .none: break
            }
        }

        presenter.view = view
    }

    func testThatWhenPresenterViewIsSetThenViewIsInitializedWithItemsInTheCorrectOrder() {
        tagRepository.learningCardsHandler = { _ in
            [.fixture(value: "spec_1"), .fixture(value: "spec_3"), .fixture(value: "spec_2")]
        }

        library.learningCardMetaItemHandler = { learningCardIdentifier in
                .fixture(learningCardIdentifier: learningCardIdentifier)
        }

        view.setTagListViewItemsHandler = { items in
            let sorted = items.sorted {
                guard let lhs = $0.learningCardMetaItem, let rhs = $1.learningCardMetaItem else { return false}
                return lhs.title < rhs.title
            }

            let itemIdentifiers = items.map { $0.learningCardMetaItem?.learningCardIdentifier }
            let sortedIdentifiers = sorted.map { $0.learningCardMetaItem?.learningCardIdentifier }

            XCTAssertEqual(itemIdentifiers, sortedIdentifiers)
        }

        presenter.view = view
    }

    func testThatAnalyticsTrackingProviderIsNotifiedWhenSelectingAnArticleFromTheRecentsAndFavoriteAndLearnedList() {

        let tags: [(Tag, Tracker.Event.Article.Referrer)] = [
            (.opened, .recentlyReadList),
            (.favorite, .favoritesList),
            (.learned, .learnedList)
        ]

        let exp = expectation(description: "Tracking provider is called")
        exp.expectedFulfillmentCount = tags.count

        for tag in tags {

            presenter = ListPresenter(coordinator: coordinator,
                                      tagRepository: tagRepository,
                                      libraryRepository: libraryRepository,
                                      tag: tag.0, trackingProvider: listTracker)
            let item = LearningCardMetaItem.fixture()

            trackingProvider.trackHandler = { event in
                switch event {
                case .article(let event):
                    switch event {
                    case .articleSelected(let articleID, let referrer):
                        XCTAssertEqual(articleID, item.learningCardIdentifier.value)
                        XCTAssertEqual(referrer, tag.1)
                        exp.fulfill()

                    default: break
                    }
                default: XCTFail()
                }
            }

            presenter.didSelectItem(item)
        }

        wait(for: [exp], timeout: 0.1)
    }

    func testThatTheEmptyStateIsSetOnTheViewWhenRecentsListIsEmpty() {
        tagRepository.learningCardsHandler = { _ in
            []
        }

        tagRepository.learningCardsSortedByDateHandler = tagRepository.learningCardsHandler

        library.learningCardMetaItemHandler = { learningCardIdentifier in
            .fixture(title: .fixture(), learningCardIdentifier: learningCardIdentifier)
        }

        let expectation = self.expectation(description: "Set empty state was called")

        // We still don't have an empty state for favorite and learned, so for now we just fulfill the expectation for them here.
        switch tag {
        case .favorite, .learned: expectation.fulfill()
        default: break
        }

        view.setEmptyViewTextHandler = { text in
            switch self.tag {
            case .opened:
                XCTAssertEqual(text, L10n.Lists.Recents.EmptyState.text)
            default:
                break
            }
            expectation.fulfill()
        }

        presenter.view = view
        wait(for: [expectation], timeout: 0.1)
    }
}
