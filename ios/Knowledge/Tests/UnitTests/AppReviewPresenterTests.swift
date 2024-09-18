//
//  AppReviewPresenterTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 28.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

class AppReviewPresenterTests: XCTestCase {

    var appReviewPresenter: AppReviewPresenter!
    var appReviewRepository: AppReviewRepositoryTypeMock!

    override func setUp() {
        appReviewRepository = AppReviewRepositoryTypeMock()
        appReviewPresenter = AppReviewPresenter(appReviewRepository: appReviewRepository)
    }

    func testThatCallingDisplayAppReviewPromptIfNeededUpdatesPromptLastDisplayDateOnTheRepositoryIfThePromptWasDisplayed() {
        appReviewRepository.shouldDisplayAppReviewPromptHandler = {
            true
        }

        appReviewPresenter.displayAppReviewPromptIfNeeded()

        XCTAssertEqual(appReviewRepository.appReviewPromptWasDisplayedCallCount, 1)
    }

    func testThatCallingDisplayAppReviewPromptIfNeededDoesNotUpdatePromptLastDisplayDateOnTheRepositoryIfThePromptWasDisplayed() {
        appReviewRepository.shouldDisplayAppReviewPromptHandler = {
            false
        }

        appReviewPresenter.displayAppReviewPromptIfNeeded()

        XCTAssertEqual(appReviewRepository.appReviewPromptWasDisplayedCallCount, 0)
    }
}
