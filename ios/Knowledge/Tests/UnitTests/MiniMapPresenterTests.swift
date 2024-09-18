//
//  MiniMapPresenterTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 07.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Foundation
import Domain
@testable import Knowledge_DE
import XCTest

class MiniMapPresenterTests: XCTestCase {
    var presenter: MiniMapPresenterType!
    var library: LibraryTypeMock!
    var coordinator: LearningCardCoordinatorTypeMock!
    var currentModes: [String]!
    var view: MiniMapViewTypeMock!

    override func setUp() {
        currentModes = ["spec_2", "spec_3"]
        library = LibraryTypeMock()

        let libraryRepository = LibraryRepositoryTypeMock()
        libraryRepository.library = library

        coordinator = LearningCardCoordinatorTypeMock()
        view = MiniMapViewTypeMock()
        presenter = MiniMapPresenter(learningCardIdentifier: LearningCardIdentifier.fixture(), coordinator: coordinator, libraryRepository: libraryRepository, currentModes: currentModes)

        library.learningCardMetaItemHandler = { _ in .fixture() }
    }

    func testThatWhenPresenterViewIsSetThenViewIsInitializedWithItemsThatAreSubsetOfCurrentUserModes() {
        let node1 = MinimapNodeMeta.fixture(childNodes: [
            MinimapNodeMeta.fixture(requiredModes: currentModes),
            MinimapNodeMeta.fixture(requiredModes: currentModes + ["spec_5", "spec_8"])
        ], requiredModes: currentModes)

        let node2 = MinimapNodeMeta.fixture(childNodes: [
            MinimapNodeMeta.fixture(requiredModes: ["spec_1", "spec_3"])
        ], requiredModes: ["spec_7", "spec_3"])

        let minimapNodes = [node1, node2]

        library.learningCardMetaItemHandler = { identifier in
            LearningCardMetaItem.fixture(minimapNodes: minimapNodes, learningCardIdentifier: identifier)
        }

        view.setHandler = { [currentModes] items in
            for item in items {
                XCTAssert(Set(item.miniMapNode.requiredModes).isSubset(of: currentModes!))
            }
        }

        presenter.view = view
    }

    func testThatWhenItemIsTappedThenCoordinatorNavigateToItemIsCalled() {
        let miniMapNode = MinimapNodeMeta.fixture(childNodes: [
            MinimapNodeMeta.fixture(requiredModes: ["spec_2", "spec_3"])
        ], requiredModes: ["spec_2", "spec_3"])

        presenter.view = view
        let expectation = self.expectation(description: "coordinator navigateHandler was called")

        coordinator.navigateHandler = { [coordinator] _, _, _ in
            XCTAssertEqual(1, coordinator?.navigateCallCount)
            expectation.fulfill()
        }

        presenter.didSelectItem(MiniMapViewItem(miniMapNode: miniMapNode, itemType: .parent))

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenItemIsTappedThenCoordinatorNavigateToItemIsCalledWithTheCorrectParameters() {
        let miniMapNode = MinimapNodeMeta.fixture()

        presenter.view = view
        let expectation = self.expectation(description: "coordinator navigateHandler was called")

        coordinator.navigateHandler = { _, snippetsAllowed, shouldPopToRoot in
            XCTAssertFalse(snippetsAllowed)
            XCTAssertFalse(shouldPopToRoot)
            expectation.fulfill()
        }

        presenter.didSelectItem(MiniMapViewItem(miniMapNode: miniMapNode, itemType: .parent))

        wait(for: [expectation], timeout: 0.1)
    }
}
