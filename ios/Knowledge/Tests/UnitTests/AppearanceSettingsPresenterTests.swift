//
//  AppearancePresenterTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 28.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

class AppearanceSettingsPresenterTests: XCTestCase {

    var presenter: AppearanceSettingsPresenter!
    var deviceSettingsRepository: DeviceSettingsRepositoryTypeMock!
    var view: AppearanceSettingsTableViewTypeMock!

    override func setUp() {
        deviceSettingsRepository = DeviceSettingsRepositoryTypeMock()
        deviceSettingsRepository.currentUserInterfaceStyle = .light
        view = AppearanceSettingsTableViewTypeMock()
        presenter = AppearanceSettingsPresenter(repository: deviceSettingsRepository, appearanceService: AppearanceApplicationServiceTypeMock())
    }

    func testThatTheViewIsSetWithTheCorrectValues() {
        deviceSettingsRepository.keepScreenOn = true

        view.setSectionsHandler = { sections in
            if case let .keepScreenOn(isEnabled) = sections[0] {
                XCTAssertEqual(isEnabled, self.deviceSettingsRepository.keepScreenOn)
            }
        }

        presenter.view = view
    }

    func testThatViewChangesAreStoredIntoTheRepository() {
        XCTAssertFalse(deviceSettingsRepository.keepScreenOn)
        presenter.keepScreenActiveDidChange(isEnabled: true)
        XCTAssertTrue(deviceSettingsRepository.keepScreenOn)
    }
}
