//
//  LearningCardTreeItemTests.swift
//  KnowledgeTests
//
//  Created by CSH on 27.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
import XCTest

class LearningCardTreeItemTests: XCTestCase {

    func testThatItParsesARootElement() {
        let fileUrl = Bundle.tests.url(forResource: "LearningCardTreeItem/SingleRootElement.json", withExtension: nil)!

        let treeItem = try? LearningCardTreeItem.objectFromFile(fileUrl)

        XCTAssertNotNil(treeItem)
        XCTAssertNil(treeItem?.parent)
    }

    func testThatItParsesAFolderReference() {
        let fileUrl = Bundle.tests.url(forResource: "LearningCardTreeItem/SingleFolderElement.json", withExtension: nil)!

        let treeItem = try? LearningCardTreeItem.objectFromFile(fileUrl)

        XCTAssertNotNil(treeItem)
        XCTAssertNil(treeItem?.learningCardIdentifier)
        XCTAssertNotNil(treeItem?.childrenCount)
    }

    func testThatItParsesALearningCardReference() {
        let fileUrl = Bundle.tests.url(forResource: "LearningCardTreeItem/SingleLearningCardElement.json", withExtension: nil)!

        let treeItem = try? LearningCardTreeItem.objectFromFile(fileUrl)

        XCTAssertNotNil(treeItem)
        XCTAssertNotNil(treeItem?.parent)
        XCTAssertNotNil(treeItem?.learningCardIdentifier)
        XCTAssertNil(treeItem?.childrenCount)
    }

    func testThatItParsesMultipleItems() {
        let fileUrl = Bundle.tests.url(forResource: "LearningCardTreeItem/MultipleElements.json", withExtension: nil)!

        let treeItems = try? LearningCardTreeItem.arrayFromFile(fileUrl)

        XCTAssertNotNil(treeItems)
        XCTAssertEqual(treeItems?.count, 2)
    }
}
