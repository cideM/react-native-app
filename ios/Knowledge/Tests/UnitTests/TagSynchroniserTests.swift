//
//  TagSynchroniserTests.swift
//  KnowledgeTests
//
//  Created by CSH on 29.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class TagSynchroniserTests: XCTestCase {
    var learningCardClient: LearningCardLibraryClientMock!
    var additionalStorage: MemoryStorage!
    var tagRepository: TagRepositoryTypeMock!
    var tagSynchroniser: TagSynchroniser!

    override func setUp() {
        additionalStorage = MemoryStorage()
        learningCardClient = LearningCardLibraryClientMock()
        tagRepository = TagRepositoryTypeMock()
        tagSynchroniser = TagSynchroniser( tagRepository: tagRepository, learningCardClient: learningCardClient, storage: additionalStorage)
    }

    func testThatSynchronizerNeedsSynchronizationIsCalledWhenNewDataIsAdded() {
        tagRepository.taggingsHandler = { _, _ in
            [.fixture()]
        }

        let expectation = self.expectation(description: "SynchronizerNeedsSynchronization notification was posted")
        let observer = NotificationCenter.default.observe(for: SynchronizerNeedsSynchronization.self, object: tagSynchroniser, queue: .main) { _ in
            expectation.fulfill()
        }
        _ = observer
        NotificationCenter.default.post(TaggingsDidChangeNotification(oldValue: [:], newValue: [.fixture(): .fixture()]), sender: tagRepository)
        wait(for: [expectation], timeout: 0.1)
    }
}
