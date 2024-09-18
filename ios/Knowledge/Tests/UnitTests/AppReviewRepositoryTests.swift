//
//  AppReviewRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 27.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

class AppReviewRepositoryTests: XCTestCase {

    var storage: Storage!
    var appReviewRepository: (AppReviewRepositoryType & TrackingType)!

    override func setUp() {
        storage = MemoryStorage()
        appReviewRepository = AppReviewRepository(storage: storage)
    }

    func testThatAppFirstLaunchDateIsPersisted() {
        storage.store(nil as Date?, for: .firstAppLaunchDate)

        appReviewRepository.track(.applicationStarted(appAppearancePreference: .light, systemAppearancePreference: .light))

        let persistedAppLaunchedDate: Date? = storage.get(for: .firstAppLaunchDate)
        XCTAssertNotNil(persistedAppLaunchedDate)
    }

    func testThatAppLauchCountIsPersisted() {
        storage.store(nil as Int?, for: .appLaunchCount)

        appReviewRepository.track(.applicationStarted(appAppearancePreference: .light, systemAppearancePreference: .light))
        appReviewRepository.track(.applicationStarted(appAppearancePreference: .light, systemAppearancePreference: .light))
        appReviewRepository.track(.applicationStarted(appAppearancePreference: .light, systemAppearancePreference: .light))

        let appLaunchCount: Int? = storage.get(for: .appLaunchCount)
        XCTAssertEqual(appLaunchCount, 3)
    }

    func testThatArticleViewCountIsPersisted() {
        storage.store(nil as Int?, for: .articleViewCount)

        let count = Int.random(in: 3...12)
        let range = 1...count
        for _ in range {
            let articleID = String.fixture()
            let title = String.fixture()
            let options = LearningCardOptions.fixture()
            appReviewRepository.track(.articleOpened(articleID: articleID, title: title, options: options))
        }

        let articleViewCount: Int? = storage.get(for: .articleViewCount)
        XCTAssertEqual(articleViewCount, count)
    }

    func testThatCallingAppReviewPromptWasDisplayedPersistsTheDateOfItsDisplay() {
        storage.store(nil as Date?, for: .appReviewPromptLastDisplayDate)

        appReviewRepository.appReviewPromptWasDisplayed()

        let appReviewPromptLastDisplayDate: Date? = storage.get(for: .appReviewPromptLastDisplayDate)
        XCTAssertNotNil(appReviewPromptLastDisplayDate)
    }

    func testThatShouldShowPromptReturnsFalseIfAppStartedForTheFirstTimeMoreRecentThanMinNumOfWeeksEvenIfOtherValuesMatchTheCriteria() {
        appReviewRepository = AppReviewRepository(storage: storage, minAppLaunchCount: 1, minArticleViewCount: 1, timeIntervalSinceFirstAppLaunch: 1.0.week, timeIntervalSinceLastAppPromptDisplay: 10.0.days)

        storage.store(10 as Int?, for: .appLaunchCount)
        storage.store(10 as Int?, for: .articleViewCount)
        storage.store(Date(), for: .firstAppLaunchDate)
        storage.store(Date(timeIntervalSinceNow: -30.0.days), for: .appReviewPromptLastDisplayDate)

        XCTAssertFalse(appReviewRepository.shouldDisplayAppReviewPrompt())
    }

    func testThatShouldShowPromptReturnsTrueIfAppStartedForTheFirstTimeEqualsMinNumOfWeeksIfOtherValuesMatchTheCriteria() {
        appReviewRepository = AppReviewRepository(storage: storage, minAppLaunchCount: 1, minArticleViewCount: 1, timeIntervalSinceFirstAppLaunch: 1.0.week, timeIntervalSinceLastAppPromptDisplay: 10.0.days)

        storage.store(10 as Int?, for: .appLaunchCount)
        storage.store(10 as Int?, for: .articleViewCount)
        storage.store(Date(timeIntervalSinceNow: -1.0.week), for: .firstAppLaunchDate)
        storage.store(Date(timeIntervalSinceNow: -30.0.days), for: .appReviewPromptLastDisplayDate)

        XCTAssert(appReviewRepository.shouldDisplayAppReviewPrompt())
    }

    func testThatShouldShowPromptReturnsTrueIfAppStartedForTheFirstTimeOlderThanMinNumOfWeeksIfOtherValuesMatchTheCriteria() {
        appReviewRepository = AppReviewRepository(storage: storage, minAppLaunchCount: 1, minArticleViewCount: 1, timeIntervalSinceFirstAppLaunch: 1.0.week, timeIntervalSinceLastAppPromptDisplay: 10.0.days)

        storage.store(10 as Int?, for: .appLaunchCount)
        storage.store(10 as Int?, for: .articleViewCount)
        storage.store(Date(timeIntervalSinceNow: -2.0.weeks), for: .firstAppLaunchDate)
        storage.store(Date(timeIntervalSinceNow: -30.0.days), for: .appReviewPromptLastDisplayDate)

        XCTAssert(appReviewRepository.shouldDisplayAppReviewPrompt())
    }

    func testThatShouldShowPromptReturnsFalseIfAppWasLaunchedForTimesLessThanTheMinLaunchCountEvenIfOtherValuesMatchTheCriteria() {
        appReviewRepository = AppReviewRepository(storage: storage, minAppLaunchCount: 5, minArticleViewCount: 1, timeIntervalSinceFirstAppLaunch: 1.0.week, timeIntervalSinceLastAppPromptDisplay: 10.0.days)

        storage.store(1 as Int?, for: .appLaunchCount)
        storage.store(10 as Int?, for: .articleViewCount)
        storage.store(Date(timeIntervalSinceNow: -2.0.weeks), for: .firstAppLaunchDate)
        storage.store(Date(timeIntervalSinceNow: -30.0.days), for: .appReviewPromptLastDisplayDate)

        XCTAssertFalse(appReviewRepository.shouldDisplayAppReviewPrompt())
    }

    func testThatShouldShowPromptReturnsTrueIfAppWasLaunchedForTimesEqualsTheMinLaunchCountIfOtherValuesMatchTheCriteria() {
        appReviewRepository = AppReviewRepository(storage: storage, minAppLaunchCount: 5, minArticleViewCount: 1, timeIntervalSinceFirstAppLaunch: 1.0.week, timeIntervalSinceLastAppPromptDisplay: 10.0.days)

        storage.store(5 as Int?, for: .appLaunchCount)
        storage.store(10 as Int?, for: .articleViewCount)
        storage.store(Date(timeIntervalSinceNow: -2.0.weeks), for: .firstAppLaunchDate)
        storage.store(Date(timeIntervalSinceNow: -30.0.days), for: .appReviewPromptLastDisplayDate)

        XCTAssert(appReviewRepository.shouldDisplayAppReviewPrompt())
    }

    func testThatShouldShowPromptReturnsTrueIfAppWasLaunchedForTimesMoreThanTheMinLaunchCountIfOtherValuesMatchTheCriteria() {
        appReviewRepository = AppReviewRepository(storage: storage, minAppLaunchCount: 5, minArticleViewCount: 1, timeIntervalSinceFirstAppLaunch: 1.0.week, timeIntervalSinceLastAppPromptDisplay: 10.0.days)

        storage.store(10 as Int?, for: .appLaunchCount)
        storage.store(10 as Int?, for: .articleViewCount)
        storage.store(Date(timeIntervalSinceNow: -2.0.weeks), for: .firstAppLaunchDate)
        storage.store(Date(timeIntervalSinceNow: -30.0.days), for: .appReviewPromptLastDisplayDate)

        XCTAssert(appReviewRepository.shouldDisplayAppReviewPrompt())
    }

    func testThatShouldShowPromptReturnsFalseIfNumOfViewedArticlesIsLessThanTheMinNumOfViewedArticlesEvenIfOtherValuesMatchTheCriteria() {
        appReviewRepository = AppReviewRepository(storage: storage, minAppLaunchCount: 1, minArticleViewCount: 5, timeIntervalSinceFirstAppLaunch: 1.0.week, timeIntervalSinceLastAppPromptDisplay: 10.0.days)

        storage.store(10 as Int?, for: .appLaunchCount)
        storage.store(1 as Int?, for: .articleViewCount)
        storage.store(Date(timeIntervalSinceNow: -2.0.weeks), for: .firstAppLaunchDate)
        storage.store(Date(timeIntervalSinceNow: -30.0.days), for: .appReviewPromptLastDisplayDate)

        XCTAssertFalse(appReviewRepository.shouldDisplayAppReviewPrompt())
    }

    func testThatShouldShowPromptReturnsFalseIfNumOfViewedArticlesEqualsTheMinNumOfViewedArticlesEvenIfOtherValuesMatchTheCriteria() {
        appReviewRepository = AppReviewRepository(storage: storage, minAppLaunchCount: 1, minArticleViewCount: 5, timeIntervalSinceFirstAppLaunch: 1.0.week, timeIntervalSinceLastAppPromptDisplay: 10.0.days)

        storage.store(10 as Int?, for: .appLaunchCount)
        storage.store(5 as Int?, for: .articleViewCount)
        storage.store(Date(timeIntervalSinceNow: -2.0.weeks), for: .firstAppLaunchDate)
        storage.store(Date(timeIntervalSinceNow: -30.0.days), for: .appReviewPromptLastDisplayDate)

        XCTAssert(appReviewRepository.shouldDisplayAppReviewPrompt())
    }

    func testThatShouldShowPromptReturnsFalseIfNumOfViewedArticlesMoreThanTheMinNumOfViewedArticlesEvenIfOtherValuesMatchTheCriteria() {
        appReviewRepository = AppReviewRepository(storage: storage, minAppLaunchCount: 1, minArticleViewCount: 5, timeIntervalSinceFirstAppLaunch: 1.0.week, timeIntervalSinceLastAppPromptDisplay: 10.0.days)

        storage.store(10 as Int?, for: .appLaunchCount)
        storage.store(10 as Int?, for: .articleViewCount)
        storage.store(Date(timeIntervalSinceNow: -2.0.weeks), for: .firstAppLaunchDate)
        storage.store(Date(timeIntervalSinceNow: -30.0.days), for: .appReviewPromptLastDisplayDate)

        XCTAssert(appReviewRepository.shouldDisplayAppReviewPrompt())
    }

    func testThatShouldShowPromptReturnsFalseIfPromptWasDisplayedMoreRecentThanTheMinNumOfMonthsSinceLastDisplayDateEvenIfOtherValuesMatchTheCriteria() {
        appReviewRepository = AppReviewRepository(storage: storage, minAppLaunchCount: 1, minArticleViewCount: 1, timeIntervalSinceFirstAppLaunch: 1.0.week, timeIntervalSinceLastAppPromptDisplay: 30.0.days)

        storage.store(10 as Int?, for: .appLaunchCount)
        storage.store(10 as Int?, for: .articleViewCount)
        storage.store(Date(timeIntervalSinceNow: -2.0.weeks), for: .firstAppLaunchDate)
        storage.store(Date(timeIntervalSinceNow: -10.0.days), for: .appReviewPromptLastDisplayDate)

        XCTAssertFalse(appReviewRepository.shouldDisplayAppReviewPrompt())
    }

    func testThatShouldShowPromptReturnsTrueIfPromptWasDisplayedSinceEqualsOlderThanTheMinNumOfMonthsSinceLastDisplayDateIfOtherValuesMatchTheCriteria() {
        appReviewRepository = AppReviewRepository(storage: storage, minAppLaunchCount: 1, minArticleViewCount: 1, timeIntervalSinceFirstAppLaunch: 1.0.week, timeIntervalSinceLastAppPromptDisplay: 30.0.days)

        storage.store(10 as Int?, for: .appLaunchCount)
        storage.store(10 as Int?, for: .articleViewCount)
        storage.store(Date(timeIntervalSinceNow: -2.0.weeks), for: .firstAppLaunchDate)
        storage.store(Date(timeIntervalSinceNow: -30.0.days), for: .appReviewPromptLastDisplayDate)

        XCTAssert(appReviewRepository.shouldDisplayAppReviewPrompt())
    }

    func testThatShouldShowPromptReturnsTrueIfPromptWasDisplayedSinceOlderThanTheMinNumOfMonthsSinceLastDisplayDateIfOtherValuesMatchTheCriteria() {
        appReviewRepository = AppReviewRepository(storage: storage, minAppLaunchCount: 1, minArticleViewCount: 1, timeIntervalSinceFirstAppLaunch: 1.0.week, timeIntervalSinceLastAppPromptDisplay: 30.0.days)

        storage.store(10 as Int?, for: .appLaunchCount)
        storage.store(10 as Int?, for: .articleViewCount)
        storage.store(Date(timeIntervalSinceNow: -2.0.weeks), for: .firstAppLaunchDate)
        storage.store(Date(timeIntervalSinceNow: -60.0.days), for: .appReviewPromptLastDisplayDate)

        XCTAssert(appReviewRepository.shouldDisplayAppReviewPrompt())
    }

    func testThatShouldShowPromptReturnsFalseIfAllCriteriaValuesAreSetToNil() {
        appReviewRepository = AppReviewRepository(storage: storage, minAppLaunchCount: 1, minArticleViewCount: 1, timeIntervalSinceFirstAppLaunch: 1.0.week, timeIntervalSinceLastAppPromptDisplay: 30.0.days)

        storage.store(nil as Int?, for: .appLaunchCount)
        storage.store(nil as Int?, for: .articleViewCount)
        storage.store(nil as Date?, for: .firstAppLaunchDate)
        storage.store(nil as Date?, for: .appReviewPromptLastDisplayDate)

        XCTAssertFalse(appReviewRepository.shouldDisplayAppReviewPrompt())
    }
}
