//
//  LibrariesSettingsPresenterTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 16.12.19.
//  Copyright © 2019 AMBOSS GmbH. All rights reserved.
//
@testable import Knowledge_DE
import XCTest

import Common
import Foundation
import Domain

class LibrariesSettingsPresenterTests: XCTestCase {

    var librarySettingsPresenter: LibrariesSettingsPresenterType!
    var libraryRepository: LibraryRepositoryTypeMock!
    var libraryUpdater: LibraryUpdaterMock!
    var librarySettingsView: LibrariesSettingsViewTypeMock!
    var pharmaUpdateService: PharmaDatabaseApplicationServiceTypeMock!

    override func setUp() {
        libraryRepository = LibraryRepositoryTypeMock()
        libraryUpdater = LibraryUpdaterMock()
        pharmaUpdateService = PharmaDatabaseApplicationServiceTypeMock(state: .checking)
        librarySettingsPresenter = LibrariesSettingsPresenter(libraryRepository: libraryRepository, libraryUpdater: libraryUpdater, pharmaDatabaseApplicationService: pharmaUpdateService)
        librarySettingsView = LibrariesSettingsViewTypeMock()
    }

    func testThatLibraryAutoWifiStateIsSetWhenPresenterViewIsSet() {
        librarySettingsPresenter.view = librarySettingsView

        XCTAssertEqual(librarySettingsView.setIsLibraryAutoUpdateEnabledCallCount, 1)
    }

    func testThatPharmaAutoWifiStateIsSetWhenPresenterViewIsSet() {
        librarySettingsPresenter.view = librarySettingsView

        XCTAssertEqual(librarySettingsView.setIsPharmaAutoUpdateEnabledCallCount, 1)
    }

    func testThatLibraryAutoWifiStateIsPersistedUponChange() {
        librarySettingsPresenter.didChangeIsAutoUpdateEnabled(true)

        XCTAssertEqual(libraryUpdater.onSetIsBackgroudUpdatesEnabledCount, 1)
    }

    func testThatPharmaAutoWifiStateIsPersistedUponChange() {
        librarySettingsPresenter.didChangePharmaIsAutoUpdateEnabled(true)

        XCTAssertEqual(pharmaUpdateService.isBackgroundUpdatesEnabledSetCallCount, 1)
    }

    func testThatTheInitialLibraryAndPharmaUpdateStateIsSetOnTheView() {
        let expectation = self.expectation(description: "Did call set state for Library")
        let expectation1 = self.expectation(description: "Did call set state for Pharma")

        libraryUpdater.onGetState = {
            .checking(isUserTriggered: false)
        }

        librarySettingsView.setStateHandler = { viewState in
            switch viewState {
            case .library(.checking):
                expectation.fulfill()
            case .pharma(.checking):
                expectation1.fulfill()
            default:
                XCTFail()
            }
        }

        librarySettingsPresenter.view = librarySettingsView

        wait(for: [expectation, expectation1], timeout: 0.1)
    }

    func testThatWhenTheLibraryStateIsChangedTheViewReflectsTheChangesForState_UpToDate() {
        librarySettingsPresenter.view = librarySettingsView
        let state: LibraryUpdaterState = .upToDate
        let pharmaState: PharmaDatabaseApplicationServiceState = .checking // This doesn't matter but we can not create fixture for it yet, because of the Error type.
        testThatThePresenterTransformsTheLibraryAndPharmaUpdateStateToTheExpectedViewState(to: state, pharmaState: pharmaState)
    }

    func testThatWhenTheLibraryStateIsChangedTheViewReflectsTheChangesForState_Checking() {
        librarySettingsPresenter.view = librarySettingsView
        let state: LibraryUpdaterState = .checking(isUserTriggered: false)
        let pharmaState: PharmaDatabaseApplicationServiceState = .checking // This doesn't matter but we can not create fixture for it yet, because of the Error type.
        testThatThePresenterTransformsTheLibraryAndPharmaUpdateStateToTheExpectedViewState(to: state, pharmaState: pharmaState)
    }

    func testThatWhenTheLibraryStateIsChangedTheViewReflectsTheChangesForState_Downloading() {
        librarySettingsPresenter.view = librarySettingsView
        let state: LibraryUpdaterState = .downloading(LibraryUpdate.fixture(), 0, isUserTriggered: false)
        let pharmaState: PharmaDatabaseApplicationServiceState = .checking // This doesn't matter but we can not create fixture for it yet, because of the Error type.
        testThatThePresenterTransformsTheLibraryAndPharmaUpdateStateToTheExpectedViewState(to: state, pharmaState: pharmaState)
    }

    func testThatWhenTheLibraryStateIsChangedTheViewReflectsTheChangesForState_Installing() {
        librarySettingsPresenter.view = librarySettingsView
        let state: LibraryUpdaterState = .installing(libraryUpdate: LibraryUpdate.fixture(), libraryZipFileName: "none")
        let pharmaState: PharmaDatabaseApplicationServiceState = .checking // This doesn't matter but we can not create fixture for it yet, because of the Error type.
        testThatThePresenterTransformsTheLibraryAndPharmaUpdateStateToTheExpectedViewState(to: state, pharmaState: pharmaState)
    }

    func testThatWhenTheLibraryStateIsChangedTheViewReflectsTheChangesForState_FailedWhenBackgroundUpdatesAreDisabled() {
        librarySettingsPresenter.view = librarySettingsView
        let state: LibraryUpdaterState = .failed(LibraryUpdate.fixture(), .backgroundUpdatesNotAllowed)
        let pharmaState: PharmaDatabaseApplicationServiceState = .checking // This doesn't matter but we can not create fixture for it yet, because of the Error type.
        testThatThePresenterTransformsTheLibraryAndPharmaUpdateStateToTheExpectedViewState(to: state, pharmaState: pharmaState)
    }

    func testThatWhenTheLibraryStateIsChangedTheViewReflectsTheChangesForState_Failed() {
        librarySettingsPresenter.view = librarySettingsView
        let state: LibraryUpdaterState = .failed(LibraryUpdate.fixture(), .storageExceeded)
        let pharmaState: PharmaDatabaseApplicationServiceState = .checking // This doesn't matter but we can not create fixture for it yet, because of the Error type.
        testThatThePresenterTransformsTheLibraryAndPharmaUpdateStateToTheExpectedViewState(to: state, pharmaState: pharmaState)
    }

    func testThatWhenThePharmaStateIsChangedTheViewReflectsTheChangesForState_UpToDate() {
        librarySettingsPresenter.view = librarySettingsView
        let state: LibraryUpdaterState = .checking(isUserTriggered: false) // This doesn't matter but we can not create fixture for it yet, because of the Error type.
        let pharmaState: PharmaDatabaseApplicationServiceState = .idle(error: nil, availableUpdate: nil, type: .automatic)
        testThatThePresenterTransformsTheLibraryAndPharmaUpdateStateToTheExpectedViewState(to: state, pharmaState: pharmaState)
    }

    func testThatWhenThePharmaStateIsChangedTheViewReflectsTheChangesForState_Checking() {
        librarySettingsPresenter.view = librarySettingsView
        let state: LibraryUpdaterState = .checking(isUserTriggered: false) // This doesn't matter but we can not create fixture for it yet, because of the Error type.
        let pharmaState: PharmaDatabaseApplicationServiceState = .checking
        testThatThePresenterTransformsTheLibraryAndPharmaUpdateStateToTheExpectedViewState(to: state, pharmaState: pharmaState)
    }

    func testThatWhenThePharmaStateIsChangedTheViewReflectsTheChangesForState_Downloading() {
        librarySettingsPresenter.view = librarySettingsView
        let state: LibraryUpdaterState = .checking(isUserTriggered: false) // This doesn't matter but we can not create fixture for it yet, because of the Error type.
        let pharmaState: PharmaDatabaseApplicationServiceState = .downloading(update: .fixture(), progress: 0)
        testThatThePresenterTransformsTheLibraryAndPharmaUpdateStateToTheExpectedViewState(to: state, pharmaState: pharmaState)
    }

    func testThatWhenThePharmaStateIsChangedTheViewReflectsTheChangesForState_Installing() {
        librarySettingsPresenter.view = librarySettingsView
        let state: LibraryUpdaterState = .checking(isUserTriggered: false) // This doesn't matter but we can not create fixture for it yet, because of the Error type.
        let pharmaState: PharmaDatabaseApplicationServiceState = .installing
        testThatThePresenterTransformsTheLibraryAndPharmaUpdateStateToTheExpectedViewState(to: state, pharmaState: pharmaState)
    }

    func testThatWhenThePharmaStateIsChangedTheViewReflectsTheChangesForState_FailedWhenBackgroundUpdatesAreDisabled() {
        librarySettingsPresenter.view = librarySettingsView
        let state: LibraryUpdaterState = .checking(isUserTriggered: false) // This doesn't matter but we can not create fixture for it yet, because of the Error type.
        let pharmaState: PharmaDatabaseApplicationServiceState = .idle(error: .updateNotAllowed, availableUpdate: nil, type: .automatic)
        testThatThePresenterTransformsTheLibraryAndPharmaUpdateStateToTheExpectedViewState(to: state, pharmaState: pharmaState)
    }

    func testThatWhenThePharmaStateIsChangedTheViewReflectsTheChangesForState_Failed() {
        librarySettingsPresenter.view = librarySettingsView
        let state: LibraryUpdaterState = .checking(isUserTriggered: false) // This doesn't matter but we can not create fixture for it yet, because of the Error type.
        let pharmaState: PharmaDatabaseApplicationServiceState = .idle(error: .notConnectedToWiFi, availableUpdate: nil, type: .automatic)
        testThatThePresenterTransformsTheLibraryAndPharmaUpdateStateToTheExpectedViewState(to: state, pharmaState: pharmaState)
    }

    func testThatForTheFirstTimeUsageViewWillBeSetToInstallPharmaDBState() {
        librarySettingsPresenter.view = librarySettingsView
        let state: LibraryUpdaterState = .checking(isUserTriggered: false) // This doesn't matter but we can not create fixture for it yet, because of the Error type.
        let pharmaState: PharmaDatabaseApplicationServiceState = .idle(error: .noDatabaseToUpdate, availableUpdate: .fixture(), type: .automatic)
        testThatThePresenterTransformsTheLibraryAndPharmaUpdateStateToTheExpectedViewState(to: state, pharmaState: pharmaState)
    }

    func testThatLibraryUpdaterGetsCalled() {
        librarySettingsPresenter.updateLibrary()

        libraryUpdater.onUpdate = { isUserTriggered in
            XCTAssertTrue(isUserTriggered)
        }
    }

    func testThatPharmaUpdaterGetsCalled() {
        librarySettingsPresenter.updatePharma()

        XCTAssertEqual(pharmaUpdateService.startManualUpdateCallCount, 1)
    }

    func testThatWhenPresentDeletePharmaDBAlertIsCalledTheViewPresentsTheAlert() {
        librarySettingsPresenter.view = librarySettingsView

        let exp = self.expectation(description: "View presents the delete alert")
        librarySettingsView.presentMessageHandler = { _, _ in
            exp.fulfill()
        }

        librarySettingsPresenter.presentDeletePharmaDatabaseAlert()
        wait(for: [exp], timeout: 0.1)
    }

    func testThatWhenDeletePharmaDBIsCalledTheViewDisablesAutoUpdatesForPharma() {
        librarySettingsPresenter.view = librarySettingsView
        pharmaUpdateService.isBackgroundUpdatesEnabled = true

        let expectation = self.expectation(description: "setIsPharmaAutoUpdateEnabled is called")
        librarySettingsView.setIsPharmaAutoUpdateEnabledHandler = { isPharmaEnabled in
            XCTAssertFalse(isPharmaEnabled)
            expectation.fulfill()
        }

        librarySettingsPresenter.deletePharmaDatabase()

        XCTAssertFalse(pharmaUpdateService.isBackgroundUpdatesEnabled)
        wait(for: [expectation], timeout: 0.1)
    }
}

private extension LibrariesSettingsPresenterTests {

    func testThatThePresenterTransformsTheLibraryAndPharmaUpdateStateToTheExpectedViewState(to state: LibraryUpdaterState, pharmaState: PharmaDatabaseApplicationServiceState) {
        let expectation = self.expectation(description: "Did call setState")

        libraryUpdater.onGetState = {
            state
        }

        librarySettingsView.setStateHandler = { viewState in
            switch viewState {
            case .library(.checking):
                if case LibraryUpdaterState.checking = state {
                    expectation.fulfill()
                }

            case .library(.failed):
                if case let LibraryUpdaterState.failed(_, error) = state {
                    switch error {
                    case .backgroundUpdatesNotAllowed:
                        XCTFail()
                    default:
                        expectation.fulfill()
                    }
                }

            case .library(.installing):
                if case LibraryUpdaterState.installing = state {
                    expectation.fulfill()
                }

            case .library(.outdated):
                if case let LibraryUpdaterState.failed(_, error) = state {
                    switch error {
                    case .backgroundUpdatesNotAllowed:
                        expectation.fulfill()
                    default:
                        XCTFail()
                    }
                }

            case .library(.downloading):
                if case LibraryUpdaterState.downloading = state {
                    expectation.fulfill()
                }

            case .library(.upToDate):
                if case LibraryUpdaterState.upToDate = state {
                    expectation.fulfill()
                }

            case .pharma(.checking):
                if case PharmaDatabaseApplicationServiceState.checking = pharmaState {
                    expectation.fulfill()
                }

            case .pharma(.failed):
                if case let PharmaDatabaseApplicationServiceState.idle(error, _, _) = pharmaState {
                    switch error {
                    case .updateNotAllowed, .noDatabaseToUpdate:
                        XCTFail()
                    default:
                        expectation.fulfill()
                    }
                }

            case .pharma(.installing):
                if case PharmaDatabaseApplicationServiceState.installing = pharmaState {
                    expectation.fulfill()
                }

            case .pharma(.outdated(_, let isPharmaDatabaseAlreadyInstalled)):
                if case let PharmaDatabaseApplicationServiceState.idle(error, _, _) = pharmaState {
                    switch error {
                    case .updateNotAllowed:
                        expectation.fulfill()
                    case .noDatabaseToUpdate:
                        guard let isPharmaDatabaseAlreadyInstalled = isPharmaDatabaseAlreadyInstalled else { return }
                        XCTAssertFalse(isPharmaDatabaseAlreadyInstalled)
                        expectation.fulfill()
                    default:
                        XCTFail()
                    }
                }

            case .pharma(.downloading):
                if case PharmaDatabaseApplicationServiceState.downloading = pharmaState {
                    expectation.fulfill()
                }

            case .pharma(.upToDate):
                if case let PharmaDatabaseApplicationServiceState.idle(error, availableUpdate, _) = pharmaState {
                    XCTAssertNil(error)
                    XCTAssertNil(availableUpdate)
                    expectation.fulfill()
                }
            }
        }

        NotificationCenter.default.post(LibraryUpdaterStateDidChangeNotification(oldValue: .upToDate, newValue: state), sender: libraryUpdater)

        wait(for: [expectation], timeout: 0.1)
    }
}
