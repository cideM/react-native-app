//
//  LibraryRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 28.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class LibraryRepositoryTests: XCTestCase {

    var libraryRepository: LibraryRepositoryType!

    override func setUp() {
        libraryRepository = LibraryRepository(baseFolder: resolve(tag: .libraryRoot))
    }

    func testThatGetLibraryRootItemsReturnAllTheParentNodes() {
        let rootItems = libraryRepository.itemsForParent(nil)
        XCTAssertEqual(rootItems.count, 13)
    }

    func testThatWeAreGettingAllTheLibraryTreeItemsWithASpecificParentId() {
        let parentItem = libraryRepository.itemsForParent(nil).first!
        let items = libraryRepository.itemsForParent(parentItem)
        XCTAssertEqual(items.count, 9)
    }

    func testThatWhenTryingToGetItemsFromANonExistingdParentIdReceivesAnEmptyArray() {
        // Negative value for id here is to make sure that
        // the parent doesn't exist and test doesn't flake
        let nonexistingParent = LearningCardTreeItem.fixture(id: -1)
        let items = libraryRepository.itemsForParent(nonexistingParent)
        XCTAssertEqual(items.count, 0)
    }
}
