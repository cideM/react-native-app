//
//  LibraryDownloadStateErrorPresenterTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 31.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest
import Localization

class LibraryDownloadStateErrorPresenterTests: XCTestCase {

    var libraryDownloadStateErrorPresenter: LibraryDownloadStateErrorPresenterType!
    var libraryUpdater: LibraryUpdaterMock!
    var messagePresenter: MessagePresenterMock!
    var storage: Storage!

    override func setUp() {
        libraryUpdater = LibraryUpdaterMock()
        storage = MemoryStorage()
        libraryDownloadStateErrorPresenter = LibraryDownloadStateErrorPresenter(libraryUpdater: libraryUpdater, storage: storage)
        messagePresenter = MessagePresenterMock()
        libraryDownloadStateErrorPresenter.messagePresenter = messagePresenter
    }

    func testThatTheRecommendedUpdateAlertIsShowForANotUserTriggeredFailedShouldUpdateIfThatAlertWasNotShownBeforeForThatUpdate() {
        libraryUpdater.onGetState = {
            .downloading(LibraryUpdate.fixture(version: 290, updateMode: .should), 0, isUserTriggered: false)
        }
        NotificationCenter.default.post(LibraryUpdaterStateDidChangeNotification(oldValue: .upToDate, newValue: libraryUpdater.state), sender: libraryUpdater)

        let exp = expectation(description: "Error was presented")
        messagePresenter.onPresent = { message, _ in
            XCTAssertEqual(message.title, L10n.RecommendUpdate.Alert.title)
            exp.fulfill()
        }
        libraryUpdater.onGetState = {
            .failed(LibraryUpdate.fixture(version: 290, updateMode: .should), .storageExceeded)
        }
        NotificationCenter.default.post(LibraryUpdaterStateDidChangeNotification(oldValue: .upToDate, newValue: libraryUpdater.state), sender: libraryUpdater)

        wait(for: [exp], timeout: 0.1)
    }

    func testThatTheRecommendedUpdateAlertIsNotShowForANotUserTriggeredFailedShouldUpdateIfThatAlertWasNotShownBeforeForThatUpdate() {
        storage.store(290, for: StorageKey.lastKnownRecommendedUpdateVersion)

        libraryUpdater.onGetState = {
            .downloading(LibraryUpdate.fixture(version: 290, updateMode: .should), 0, isUserTriggered: false)
        }
        NotificationCenter.default.post(LibraryUpdaterStateDidChangeNotification(oldValue: .upToDate, newValue: libraryUpdater.state), sender: libraryUpdater)

        libraryUpdater.onGetState = {
            .failed(LibraryUpdate.fixture(version: 290, updateMode: .should), .storageExceeded)
        }
        NotificationCenter.default.post(LibraryUpdaterStateDidChangeNotification(oldValue: .upToDate, newValue: libraryUpdater.state), sender: libraryUpdater)

        XCTAssertEqual(messagePresenter.onPresentCount, 0)
    }

    func testThatTheManualUpdateAlertIsShownForAUserTriggeredFailedShouldUpdate() {
        libraryUpdater.onGetState = {
            .downloading(LibraryUpdate.fixture(updateMode: .should), 0, isUserTriggered: true)
        }
        NotificationCenter.default.post(LibraryUpdaterStateDidChangeNotification(oldValue: .upToDate, newValue: libraryUpdater.state), sender: libraryUpdater)
        let error = LibraryUpdateError.storageExceeded

        let exp = expectation(description: "Error was presented")
        messagePresenter.onPresent = { message, _ in
            XCTAssertEqual(message.body, error.body)
            exp.fulfill()
        }
        libraryUpdater.onGetState = {
            .failed(LibraryUpdate.fixture(updateMode: .should), error)
        }
        NotificationCenter.default.post(LibraryUpdaterStateDidChangeNotification(oldValue: .upToDate, newValue: libraryUpdater.state), sender: libraryUpdater)

        wait(for: [exp], timeout: 0.1)
    }
}
