//
//  SettingsPresenterTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 08.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
@testable import Knowledge_DE
import XCTest
import Foundation
import Domain
import Networking
import Localization

class SettingsPresenterTests: XCTestCase {

    private var presenter: SettingsPresenterType!
    private var view: SettingsViewTypeMock!
    private var libraryRepository: LibraryRepositoryTypeMock!
    private var libraryUpdater: LibraryUpdaterType!
    private var coodinator: SettingsCoordinatorTypeMock!
    private var pharmaDatabaseApplicationService: PharmaDatabaseApplicationServiceTypeMock!
    private var appConfiguration: ConfigurationMock!
    private var authorizationRepository: AuthorizationRepositoryTypeMock!
    private var deviceSettingsRepository: DeviceSettingsRepositoryTypeMock!
    private var appearanceService: AppearanceApplicationServiceTypeMock!

    override func setUp() {
        libraryRepository = LibraryRepositoryTypeMock()
        libraryUpdater = LibraryUpdaterMock()
        view = SettingsViewTypeMock()
        coodinator = SettingsCoordinatorTypeMock()
        appConfiguration = ConfigurationMock(appVariant: .wissen)
        authorizationRepository = AuthorizationRepositoryTypeMock()
        appearanceService = AppearanceApplicationServiceTypeMock()

        pharmaDatabaseApplicationService = PharmaDatabaseApplicationServiceTypeMock(state: .checking)
        deviceSettingsRepository = DeviceSettingsRepositoryTypeMock(keepScreenOn: true,
                                                                    currentFontScale: .random(in: 1...100),
                                                                    currentUserInterfaceStyle: .dark)

        presenter = SettingsPresenter(
            coordinator: coodinator,
            libraryUpdater: libraryUpdater,
            pharmaDatabaseApplicationService: pharmaDatabaseApplicationService,
            userDataRepositoryType: UserDataRepository(storage: MemoryStorage()),
            featureFlagRepository: FeatureFlagRepositoryTypeMock(),
            appConfiguration: appConfiguration,
            authorizationRepository: authorizationRepository,
            deviceSettingsRepository: deviceSettingsRepository,
            appearanceService: appearanceService)
    }

    func testThatAccountSectionShowsTheEmailOfTheUser() {

        authorizationRepository.authorization = Authorization.fixture()
        let email = authorizationRepository.authorization?.user.email

        let expectation = self.expectation(description: "Email was set on the view")
        view.setHandler = { sections in
            let accountSettings = sections
                .flatMap { $0.items }
                .first(where: { $0.itemType == .accountSettings })
            XCTAssertEqual(email, accountSettings?.title)
            expectation.fulfill()
        }

        presenter.view = view
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTheSectionsSetToTheViewContainsStudyObjectiveItemIfTheAppConfigurationHasStudyObjective() {
        appConfiguration.hasStudyObjective = true

        let expectation = self.expectation(description: "Sections were set on the view")
        view.setHandler = { sections in
            let containsStudyObjective = sections
                .flatMap { $0.items }
                .contains { $0.itemType == .studyobjective }
            XCTAssertTrue(containsStudyObjective)
            expectation.fulfill()
        }

        presenter.view = view
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatTheSectionsSetToTheViewDoesNotContainStudyObjectiveItemIfTheAppConfigurationDoesNotHaveStudyObjective() {
        appConfiguration.hasStudyObjective = false

        let expectation = self.expectation(description: "Sections were set on the view")
        view.setHandler = { sections in
            let containsStudyObjective = sections
                .flatMap { $0.items }
                .contains { $0.itemType == .studyobjective }
            XCTAssertFalse(containsStudyObjective)
            expectation.fulfill()
        }

        presenter.view = view
        wait(for: [expectation], timeout: 0.1)
    }

    func testThatWhenItemIsSelectedThanPresenterCallsTheCoodinatorGoToViewControllerWithCorrectItemType() {
        let item = Settings.Item(title: "Any", subtitle: "", hasChevron: true, subtitleWarning: false, itemType: .accountSettings)

        presenter.view = view

        let expectation = self.expectation(description: "Coodinator goto view controller is called")

        coodinator.goToViewControllerHandler = { itemType, _ in
            XCTAssertEqual(itemType, item.itemType)
            expectation.fulfill()
        }

        presenter.didSelect(item: item)

        wait(for: [expectation], timeout: 0.1)
    }

    // MARK: - Library status update tests

    func testThatLibraryAndPharmaUpdateStateIsPropagatedToTheView_ForState_UpToDate() {
        let state: LibraryUpdaterState = .upToDate
        let pharmaState: PharmaDatabaseApplicationServiceState = .idle(error: nil, availableUpdate: nil, type: .fixture())
        testThatLibraryUpdateStateIsPropagatedToTheView(for: state, pharmaState: pharmaState, with: L10n.LibrarySettings.updated)
    }

    func testThatLibraryAndPharmaUpdateStateIsPropagatedToTheView_ForState_Checking() {
        let state: LibraryUpdaterState = .checking(isUserTriggered: false)
        let pharmaState: PharmaDatabaseApplicationServiceState = .checking
        testThatLibraryUpdateStateIsPropagatedToTheView(for: state, pharmaState: pharmaState, with: L10n.LibrarySettings.checkingForUpdateMessage)
    }

    func testThatLibraryUpdateStateIsPropagatedToTheView_ForState_Downloading() {
        let state: LibraryUpdaterState = .downloading(LibraryUpdate.fixture(), 0, isUserTriggered: false)
        let pharmaState: PharmaDatabaseApplicationServiceState = .downloading(update: .fixture(), progress: 0)
        testThatLibraryUpdateStateIsPropagatedToTheView(for: state, pharmaState: pharmaState, with: L10n.LibrarySettings.updatingMessage)
    }

    func testThatLibraryAndPharmaUpdateStateIsPropagatedToTheView_ForState_Installing() {
        let state: LibraryUpdaterState = .installing(libraryUpdate: LibraryUpdate.fixture(), libraryZipFileName: "none")
        let pharmaState: PharmaDatabaseApplicationServiceState = .installing
        testThatLibraryUpdateStateIsPropagatedToTheView(for: state, pharmaState: pharmaState, with: L10n.LibrarySettings.updatingMessage)
    }

    func testThatLibraryUpdateStateIsPropagatedToTheView_ForState_FailedWhenBackgroundUpdatesAreDisabled() {
        let state: LibraryUpdaterState = .failed(LibraryUpdate.fixture(), .backgroundUpdatesNotAllowed)
        let pharmaState: PharmaDatabaseApplicationServiceState = .idle(error: nil, availableUpdate: nil, type: .fixture())
        testThatLibraryUpdateStateIsPropagatedToTheView(for: state, pharmaState: pharmaState, with: L10n.LibrarySettings.updateAvailableMessage)
    }

    func testThatPharmaUpdateStateIsPropagatedToTheView_ForState_FailedWhenBackgroundUpdatesAreDisabled() {
        let state: LibraryUpdaterState = .upToDate
        let pharmaState: PharmaDatabaseApplicationServiceState = .idle(error: .updateNotAllowed, availableUpdate: .fixture(), type: .fixture())
        testThatLibraryUpdateStateIsPropagatedToTheView(for: state, pharmaState: pharmaState, with: L10n.LibrarySettings.updateAvailableMessage)
    }

    func testThatLibraryUpdateStateIsPropagatedToTheView_ForState_Failed() {
        // Error message is the same for all errors except .backgroundUpdatesNotAllowed
        let state: LibraryUpdaterState = .failed(LibraryUpdate.fixture(), .storageExceeded)
        let pharmaState: PharmaDatabaseApplicationServiceState = .idle(error: nil, availableUpdate: nil, type: .fixture())
        testThatLibraryUpdateStateIsPropagatedToTheView(for: state, pharmaState: pharmaState, with: L10n.LibrarySettings.updateAvailableMessage)
    }

    func testThatPharmaUpdateStateIsPropagatedToTheView_ForState_Failed() {
        // Error message is the same for all errors except .backgroundUpdatesNotAllowed
        let state: LibraryUpdaterState = .upToDate
        let pharmaState: PharmaDatabaseApplicationServiceState = .idle(error: .busy, availableUpdate: .fixture(), type: .fixture())
        testThatLibraryUpdateStateIsPropagatedToTheView(for: state, pharmaState: pharmaState, with: L10n.LibrarySettings.updateAvailableMessage)
    }
}

private extension SettingsPresenterTests {

    func testThatLibraryUpdateStateIsPropagatedToTheView(for state: LibraryUpdaterState, pharmaState: PharmaDatabaseApplicationServiceState, with message: String) {

        let expectation = self.expectation(description: "settings view updates when library or pharma state changes")

        presenter.view = view
        view.setHandler = { sections in
            XCTAssert(sections.containsSubtitle(matching: message))
            expectation.fulfill()
        }

        // Post library notification and update the mock accordingly
        // The content of the notification itself does not matter here
        // Because the presenter updates the view directly with the value from the library updater and pharmaDatabaseApplicationService
        // The notificatin is still required in order to acutally trigger the view update
        (libraryUpdater as! LibraryUpdaterMock).onGetState = { state }
        pharmaDatabaseApplicationService.state = pharmaState

        NotificationCenter.default.post(LibraryUpdaterStateDidChangeNotification(oldValue: .upToDate, newValue: state), sender: libraryUpdater)

        wait(for: [expectation], timeout: 0.1)
    }
}

private extension Array where Element == Settings.Section {

    func containsSubtitle(matching string: String) -> Bool {
        self
            .flatMap({ $0.items })
            .compactMap({ $0.subtitle })
            .contains(string)
    }
}
