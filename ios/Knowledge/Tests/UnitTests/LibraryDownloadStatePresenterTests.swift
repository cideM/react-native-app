//
//  LibraryDownloadStatePresenterTests.swift
//  KnowledgeTests
//
//  Created by Azadeh Richter on 28.10.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

class LibraryDownloadStatePresenterTests: XCTestCase {

    var libraryDownloadStatePresenter: LibraryDownloadStatePresenterType!
    var libraryUpdater: LibraryUpdaterMock!
    var view: LibraryDownloadStateViewMock!

    override func setUp() {
        super.setUp()
        libraryUpdater = LibraryUpdaterMock()
        view = LibraryDownloadStateViewMock()
        libraryDownloadStatePresenter = LibraryDownloadStatePresenter(libraryUpdater: libraryUpdater)
        libraryDownloadStatePresenter.view = view
    }

    func testThatPresenterCallsSetIsUpToDateOnViewWhenStateChangesToUpToDate() {
        // setIsUpdateToDate() is called once when setting the view on the presenter
        XCTAssertEqual(view.setIsUpToDateCallCount, 1)
        libraryUpdater.onGetState = {
            .upToDate
        }
        NotificationCenter.default.post(LibraryUpdaterStateDidChangeNotification(oldValue: .upToDate, newValue: libraryUpdater.state), sender: libraryUpdater)
        XCTAssertEqual(view.setIsUpToDateCallCount, 2)
        XCTAssertEqual(view.setInstallingCallCount, 0)
        XCTAssertEqual(view.setIsFailedCallCount, 0)
    }

    func testThatPresenterCallsSetIsUpToDateOnViewWhenStateChangesToChecking() {
        // setIsUpdateToDate() is called once when setting the view on the presenter
        XCTAssertEqual(view.setIsUpToDateCallCount, 1)
        libraryUpdater.onGetState = {
            // The value of `isUserTriggered` does not have an impact on the test
            .checking(isUserTriggered: false)
        }
        NotificationCenter.default.post(LibraryUpdaterStateDidChangeNotification(oldValue: .upToDate, newValue: libraryUpdater.state), sender: libraryUpdater)
        XCTAssertEqual(view.setIsUpToDateCallCount, 2)
        XCTAssertEqual(view.setInstallingCallCount, 0)
        XCTAssertEqual(view.setIsFailedCallCount, 0)
    }

    func testThatPresenterCallsNoMethodsOnViewWhenStateChangesToDownloading() {
        libraryUpdater.onGetState = {
            // The values of the associtaed values do not have an impact on the test
            .downloading(.fixture(), 0.1, isUserTriggered: false)
        }
        NotificationCenter.default.post(LibraryUpdaterStateDidChangeNotification(oldValue: .upToDate, newValue: libraryUpdater.state), sender: libraryUpdater)
        // setIsUpdateToDate() is called once when setting the view on the presenter
        XCTAssertEqual(view.setIsUpToDateCallCount, 1)
        XCTAssertEqual(view.setInstallingCallCount, 0)
        XCTAssertEqual(view.setIsFailedCallCount, 0)
    }

    func testThatPresenterCallsNoMethodsOnViewWhenStateChangesToInstalling() {
        libraryUpdater.onGetState = {
            // The values of the associtaed values do not have an impact on the test
            .installing(libraryUpdate: .fixture(), libraryZipFileName: .fixture())
        }
        NotificationCenter.default.post(LibraryUpdaterStateDidChangeNotification(oldValue: .upToDate, newValue: libraryUpdater.state), sender: libraryUpdater)
        // setIsUpdateToDate() is called once when setting the view on the presenter
        XCTAssertEqual(view.setIsUpToDateCallCount, 1)
        XCTAssertEqual(view.setInstallingCallCount, 0)
        XCTAssertEqual(view.setIsFailedCallCount, 0)
    }

    func testThatPresenterCallsSetIsFailedOnViewWhenStateChangedToFailed() {
        libraryUpdater.onGetState = {
            // The values of the associtaed values do not have an impact on the test
            .failed(.fixture(), .storageExceeded)
        }
        NotificationCenter.default.post(LibraryUpdaterStateDidChangeNotification(oldValue: .upToDate, newValue: libraryUpdater.state), sender: libraryUpdater)
        // setIsUpdateToDate() is called once when setting the view on the presenter
        XCTAssertEqual(view.setIsUpToDateCallCount, 1)
        XCTAssertEqual(view.setInstallingCallCount, 0)
        XCTAssertEqual(view.setIsFailedCallCount, 1)
    }

}
