//
//  LibraryTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 27.11.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class LibraryTests: XCTestCase {

    var library: Library!

    override func setUp() {
        library = try! Library.Fixture.valid()
    }

    func testThatItemsWithoutTitleAreFilteredOutInLearningCardTree() throws {
        // Given
        guard let url = Bundle.tests.url(forResource: "lctree", withExtension: "json") else { return }
        let learningCardTreeItems = try? LearningCardTreeItem.arrayFromFile(url)
            .filter { !$0.title.isEmpty }

        // When
        let library = try Library.Fixture.valid()

        // Then
        XCTAssertEqual(learningCardTreeItems?.count, library.learningCardTreeItems.count)
    }

    func testThatExpectdMetadaIsReturned() throws {
        let learningCardMetadata = try library.learningCardMetaItem(for: .fixture(value: "9n0Nvg"))

        XCTAssertEqual(learningCardMetadata.title, "Fall (eDocTrainer): Älterer Mann mit Sehstörung1")
        XCTAssertEqual(learningCardMetadata.minimapNodes, [MinimapNodeMeta(title: "Patientenvorstellung", anchor: .fixture(value: "ez1x7j0"), childNodes: [], requiredModes: [])])
        XCTAssertEqual(learningCardMetadata.urlPath, "Fall_%28eDocTrainer%29%3A_%C3%84lterer_Mann_mit_Sehst%C3%B6rung")
        XCTAssertEqual(learningCardMetadata.preclinicFocusAvailable, false)
        XCTAssertEqual(learningCardMetadata.alwaysFree, false)
        XCTAssertEqual(learningCardMetadata.galleries, [])
    }
}
