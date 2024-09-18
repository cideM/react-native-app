//
//  FeedbackPresenterTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 23.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
import Common
import Foundation
import Domain
@testable import Knowledge_DE
import XCTest

class FeedbackPresenterTests: XCTestCase {
    var presenter: FeedbackPresenterType!

    var feedbackDeeplink: FeedbackDeeplink!
    var repository: FeedbackRepositoryTypeMock!
    var view: FeedbackViewTypeMock!
    var coordinator: LearningCardCoordinatorTypeMock!
    var configuration: ConfigurationMock!

    override func setUp() {
        feedbackDeeplink = FeedbackDeeplink(anchor: LearningCardAnchorIdentifier(value: "SXayxQ"), version: nil, archiveVersion: 233)

        repository = FeedbackRepositoryTypeMock()
        view = FeedbackViewTypeMock()
        coordinator = LearningCardCoordinatorTypeMock()
        configuration = ConfigurationMock()

        presenter = FeedbackPresenter(feedbackRepository: repository, deepLink: feedbackDeeplink, coordinator: coordinator, configuration: configuration)
        presenter.view = view
    }

    func testThatWhenFeedbackIsSentThenViewIsDismissed() {
        configuration.appVariant = .fixture()
        presenter.selectedIntention = .fixture()
        presenter.feedbackText = .fixture()

        XCTAssertEqual(coordinator.dismissFeedbackViewCallCount, 0)

        presenter.submitFeedback()

        XCTAssertEqual(coordinator.dismissFeedbackViewCallCount, 1)
    }

    func testThatWhenFeedbackIsSentThenAddFeedbackRepositoryCallIsTriggered() {
        configuration.appVariant = .fixture()
        presenter.selectedIntention = .fixture()
        presenter.feedbackText = .fixture()

        XCTAssertEqual(repository.addFeedbackCallCount, 0)

        presenter.submitFeedback()

        XCTAssertEqual(repository.addFeedbackCallCount, 1)
    }

    func testThatTheViewIsAskedToShowMessageTextViweWhenAnIntentionIsSelected() {
        XCTAssertEqual(view.showMessageTextViewCallCount, 0)

        presenter.selectedIntention = .fixture()

        XCTAssertEqual(view.showMessageTextViewCallCount, 1)
    }

    func testThatEnteringFeedbackTextDoesNotActivateSubmitFeedbackButtonIfThereIsNoIntentionSelected() {
        configuration.appVariant = .fixture()
        presenter.selectedIntention = nil

        let expectation = self.expectation(description: "setSubmitFeedbackButtonIsEnabled was called")
        view.setSubmitFeedbackButtonIsEnabledHandler = { isEnabled in
            XCTAssertFalse(isEnabled)
            expectation.fulfill()
        }

        presenter.feedbackText = .fixture()

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatActivateSubmitFeedbackButtonIsEnabledWhenWhenBothAnIntentionIsSelectedAndFeedbackTextIsEntered() {
        configuration.appVariant = .fixture()
        presenter.selectedIntention = .fixture()

        let expectation = self.expectation(description: "setSubmitFeedbackButtonIsEnabled was called")
        view.setSubmitFeedbackButtonIsEnabledHandler = { isEnabled in
            XCTAssertTrue(isEnabled)
            expectation.fulfill()
        }

        presenter.feedbackText = .fixture()

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatCallingSelectIntentionTappedAsksTheViewToShowTheIntentionsMenuWithTheRightIntentions() {
        let expectedIntentions = FeedbackIntention.allCases
        let expectation = self.expectation(description: "showIntentionsMenu was called")
        view.showIntentionsMenuHandler = { intentions in
            XCTAssertEqual(expectedIntentions, intentions)
            expectation.fulfill()
        }

        presenter.selectIntentionTapped()

        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenSubmitFeedbackIsCalledTheRepositoryReceivesTheFeedbackWithTheRightInformation() {
        let appVariant: AppVariant = .fixture()
        let selectedIntention: FeedbackIntention = .fixture()
        let feedbackText: String = .fixture()

        configuration.appVariant = appVariant
        presenter.selectedIntention = selectedIntention
        presenter.feedbackText = feedbackText

        let expectation = self.expectation(description: "addFeedback was called")
        repository.addFeedbackHandler = { feedback in
            XCTAssertEqual(feedback.message, feedbackText)
            XCTAssertEqual(feedback.intention, selectedIntention)

            XCTAssertEqual(feedback.source.type, .particle)
            XCTAssertEqual(feedback.source.id, self.feedbackDeeplink.anchor!.value)
            XCTAssertEqual(feedback.source.version, self.feedbackDeeplink.version)

            let expectedAppName: SectionFeedback.MobileInfo.AppName = appVariant == .wissen ? .wissen : .knowledge
            XCTAssertEqual(feedback.mobileInfo.appName, expectedAppName)
            XCTAssertEqual(feedback.mobileInfo.appPlatform, .ios)
            XCTAssertEqual(feedback.mobileInfo.archiveVersion, self.feedbackDeeplink.archiveVersion)
            XCTAssertEqual(feedback.mobileInfo.appVersion, Application.main.version)

            expectation.fulfill()
        }

        presenter.submitFeedback()
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatFeedbackIsNotAddedToTheRepositoryIfNoIntentionSelected() {
        configuration.appVariant = .fixture()
        presenter.feedbackText = .fixture()

        XCTAssertEqual(repository.addFeedbackCallCount, 0)

        presenter.submitFeedback()

        XCTAssertEqual(repository.addFeedbackCallCount, 0)
    }

    func testThatFeedbackIsNotAddedToTheRepositoryIfNoFeedbackTextEntered() {
        configuration.appVariant = .fixture()
        presenter.selectedIntention = .fixture()

        XCTAssertEqual(repository.addFeedbackCallCount, 0)

        presenter.submitFeedback()

        XCTAssertEqual(repository.addFeedbackCallCount, 0)
    }
}
