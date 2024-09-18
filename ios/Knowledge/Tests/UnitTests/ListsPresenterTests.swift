//
//  ListsPresenterTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 28.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class ListsPresenterTests: XCTestCase {
    var presenter: ListsPresenterType!
    var coordinator: ListsCoordinatorTypeMock!
    var library: LibraryTypeMock!
    var libraryRepository: LibraryRepositoryTypeMock!
    var view: ListsViewTypeMock!

    override func setUp() {
        view = ListsViewTypeMock()
        coordinator = ListsCoordinatorTypeMock()
        library = LibraryTypeMock()
        libraryRepository = LibraryRepositoryTypeMock()
        libraryRepository.library = library
        presenter = ListsPresenter(coordinator: coordinator)
    }

    func testThatWhenItemIsSelectedThenViewSelectItemIsCalledWithProperItem() {
        presenter.view = view

        view.selectHandler = { item in
            XCTAssertEqual(item, .recents)
        }

        presenter.select(.recents)
    }

    func testThatPresenterTellsTheCoordinatorToOpenFavourites() {
        presenter.goToItem(.favourites)
        XCTAssertEqual(coordinator.openFavouritesCallCount, 1)
    }

    func testThatPresenterTellsTheCoordinatorToOpenLearned() {
        presenter.goToItem(.learned)
        XCTAssertEqual(coordinator.openLearnedCallCount, 1)
    }

    func testThatPresenterTellsTheCoordinatorToOpenNotes() {
        presenter.goToItem(.notes)
        XCTAssertEqual(coordinator.openNotesCallCount, 1)
    }

    func testThatPresenterTellsTheCoordinatorToOpenRecents() {
        presenter.goToItem(.recents)
        XCTAssertEqual(coordinator.openRecentsCallCount, 1)
    }
}
