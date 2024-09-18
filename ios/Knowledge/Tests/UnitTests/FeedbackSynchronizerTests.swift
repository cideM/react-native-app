//
//  FeedbackSynchronizerTests.swift
//  KnowledgeTests
//
//  Created by CSH on 29.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class FeedbackSynchronizerTests: XCTestCase {

    var learningCardClient: LearningCardLibraryClientMock!
    var feedbackRepository: FeedbackRepositoryTypeMock!
    var feedbackSynchroniser: FeedbackSynchronizer!

    override func setUp() {
        learningCardClient = LearningCardLibraryClientMock()
        feedbackRepository = FeedbackRepositoryTypeMock()
        feedbackSynchroniser = FeedbackSynchronizer(learningCardClient: learningCardClient, feedbackRepository: feedbackRepository)
    }

    func testThatSynchronizationNeedsSynchronizationIsCalledWhenANewFeedbackIsAdded() {
        let expectation = self.expectation(description: "SynchronizerNeedsSynchronization notification was posted")
        let observer = NotificationCenter.default.observe(for: SynchronizerNeedsSynchronization.self, object: feedbackSynchroniser, queue: .main) { _ in
            expectation.fulfill()
        }
        _ = observer
        NotificationCenter.default.post(FeedbacksDidChangeNotification(oldValue: [], newValue: [.fixture()]), sender: feedbackRepository)
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatNeedsSynchronizationIsNotSetToTrueIfAllFeedbacksAreRemoved() {
        let expectation = self.expectation(description: "We waited for 100 ms")
        let observer = NotificationCenter.default.observe(for: SynchronizerNeedsSynchronization.self, object: feedbackSynchroniser, queue: .main) { _ in
            XCTFail("This notification should not be posted")
        }
        _ = observer
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        NotificationCenter.default.post(FeedbacksDidChangeNotification(oldValue: [.fixture()], newValue: []), sender: feedbackRepository)
        wait(for: [expectation], timeout: 2)
    }
}
