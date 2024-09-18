//
//  LibraryPresenterTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 29.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Common
import Foundation
import Domain
@testable import Knowledge_DE
import XCTest

class LibraryPresenterTests: XCTestCase {

    var library: LibraryTypeMock!
    var libraryRepository: LibraryRepositoryTypeMock!
    var libraryCoordinator: LibraryCoordinatorTypeMock!
    var libraryPresenter: LibraryPresenterType!
    var tagTepository: TagRepositoryType!
    var trackingProvider: TrackingTypeMock!

    override func setUp() {
        library = LibraryTypeMock()
        libraryRepository = LibraryRepositoryTypeMock(library: library, learningCardStack: PointableStack<LearningCardDeeplink>())
        libraryCoordinator = LibraryCoordinatorTypeMock()
        tagTepository = TagRepository(storage: MemoryStorage())
        trackingProvider = TrackingTypeMock()
        libraryPresenter = LibraryPresenter(coordinator: libraryCoordinator, libraryRepository: libraryRepository, trackingProvider: trackingProvider, tagRepository: tagTepository)
    }

    func testThatTheCoordinatorIsAskedToGoToAnotherLibraryTreeItemWhenALibraryTreeItemIsTapped() {
        let expectation = self.expectation(description: "Called goToLibraryTreeItem")
        library.learningCardTreeItems = [LearningCardTreeItem.fixture(learningCardIdentifier: nil)]
        libraryCoordinator.goToLibraryTreeItemHandler = { item in
            XCTAssertEqual(item, self.library.learningCardTreeItems.first!)
            expectation.fulfill()
        }

        libraryPresenter.didSelectItem(library.learningCardTreeItems.first!)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTheCoordinatorIsAskedToGoToALearningCardWhenALearningCardItemIsTapped() {
        let expectation = self.expectation(description: "Called goToLearningCardItem")
        library.learningCardTreeItems = [LearningCardTreeItem.fixture(learningCardIdentifier: .some(.fixture()))]
        libraryCoordinator.goToLearningCardItemHandler = { item in
            let treeItem: LearningCardTreeItem = self.library.learningCardTreeItems.first!
            XCTAssertEqual(item, treeItem.learningCardIdentifier)
            expectation.fulfill()
        }

        libraryPresenter.didSelectItem(library.learningCardTreeItems.first!)

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatThePresenterShowsItemsBasedOnTheParent() {
        let expectation = self.expectation(description: "Called setLearningCardTreeItems")
        let parentItem = LearningCardTreeItem.fixture()
        let item = LearningCardTreeItem.fixture()

        libraryRepository.itemsForParentHandler = { parent in
            XCTAssertEqual(parent, parentItem)
            return [item]
        }
        libraryPresenter = LibraryPresenter(coordinator: libraryCoordinator, libraryRepository: libraryRepository, parent: parentItem, tagRepository: TagRepositoryTypeMock())

        let view = LibraryViewTypeMock()
        view.setLearningCardTreeItemsHandler = { items in
            XCTAssertEqual(items.count, 1)
            XCTAssertEqual(items.first, item)
            expectation.fulfill()
        }

        libraryPresenter.view = view

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatThePresenterUpdatesTheViewIfTheLibraryDidUpdate() {
        let expectation = self.expectation(description: "Called setLearningCardTreeItems")
        let items = [LearningCardTreeItem.fixture(id: Int.fixture(), parent: nil)]
        library.learningCardTreeItems = items

        libraryPresenter = LibraryPresenter(coordinator: libraryCoordinator, libraryRepository: libraryRepository, tagRepository: TagRepositoryTypeMock())

        libraryRepository.itemsForParentHandler = { _ in
            items
        }

        let view = LibraryViewTypeMock()
        libraryPresenter.view = view

        view.setLearningCardTreeItemsHandler = { itms in
            XCTAssertEqual(itms, items)
            expectation.fulfill()
        }

        NotificationCenter.default.post(LibraryDidChangeNotification(oldValue: LibraryTypeMock(), newValue: LibraryTypeMock()), sender: libraryRepository)

        wait(for: [expectation], timeout: 100.1)
    }

    func testThatTheCoordinatorShowsTheSearchViewWhenTheSearchBarIsSelected() {
        libraryPresenter.didSelectSearch()

        XCTAssertEqual(self.libraryCoordinator.showSearchViewCallCount, 1)
    }

    func testThatWhenTaggingsAreChangedTheViewIsCalledToReloadData() {
        let view = LibraryViewTypeMock()
        libraryPresenter.view = view

        let expectation = self.expectation(description: "setLearningCardTreeItemsHandler is called.")
        view.setLearningCardTreeItemsHandler = { _ in
            expectation.fulfill()
        }

        tagTepository.addTag(.favorite, for: .fixture())

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatAnalyticsProviderCallsTheRightEventWhenALearningCardItemIsTapped() {
        let expectation = self.expectation(description: "Tracking provider was called")

        library.learningCardTreeItems = [LearningCardTreeItem.fixture(learningCardIdentifier: .some(.fixture()))]
        let treeItem: LearningCardTreeItem = library.learningCardTreeItems.first!

        trackingProvider.trackHandler = { event in
            switch event {
            case .article(let articleEvent):
                switch articleEvent {
                case .articleSelected(let articleID, let referrer):
                    XCTAssertEqual(articleID, treeItem.learningCardIdentifier?.value)
                    XCTAssertEqual(referrer, .library)
                    expectation.fulfill()
                default: XCTFail("Unexpected event")
                }
            default:
                XCTFail("Unexpected event")
            }
        }

        libraryPresenter.didSelectItem(library.learningCardTreeItems.first!)
        wait(for: [expectation], timeout: 0.1)
    }
}
