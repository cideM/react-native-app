//
//  ExtensionSynchroniserTests.swift
//  KnowledgeTests
//
//  Created by CSH on 29.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class ExtensionSynchroniserTests: XCTestCase {
    var additionalExtensionStorage: MemoryStorage!
    var learningCardClient: LearningCardLibraryClientMock!
    var extensionRepository: ExtensionRepositoryTypeMock!
    var extensionSynchroniser: ExtensionSynchroniser!

    override func setUp() {
        additionalExtensionStorage = MemoryStorage()
        learningCardClient = LearningCardLibraryClientMock()
        extensionRepository = ExtensionRepositoryTypeMock()
        extensionSynchroniser = ExtensionSynchroniser(extensionRepository: extensionRepository, learningCardClient: learningCardClient, storage: additionalExtensionStorage)
    }

    func testThatSynchronizerNeedsSynchronizationIsCalledWhenANewExtensionIsAdded() {
        extensionRepository.extensionsToBeUploadedHandler = { [.fixture()] }

        let expectation = self.expectation(description: "SynchronizerNeedsSynchronization notification was posted")
        let observer = NotificationCenter.default.observe(for: SynchronizerNeedsSynchronization.self, object: extensionSynchroniser, queue: .main) { _ in
            expectation.fulfill()
        }

        _ = observer
        NotificationCenter.default.post(ExtensionsDidChangeNotification(oldValue: [], newValue: [.fixture()]), sender: extensionRepository)
        wait(for: [expectation], timeout: 0.1)
    }
}
