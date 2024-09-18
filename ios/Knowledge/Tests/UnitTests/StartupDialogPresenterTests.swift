//
//  StartupDialogPresenterTests.swift
//  KnowledgeTests
//
//  Created by Manaf Alabd Alrahim on 16.05.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class StartupDialogPresenterTests: XCTestCase {

    var startupDialogPresenter: StartupDialogPresenter!

    var startupDialogCoordinator: StartupDialogCoordinatorTypeMock!
    var trackingProvider: TrackingTypeMock!
    var appConfiguration: ConfigurationMock!
    var storage: Storage!
    var remoteConfigRepository: RemoteConfigRepositoryTypeMock!
    var consentApplicationService: ConsentApplicationServiceTypeMock!

    override func setUp() {
        startupDialogCoordinator = StartupDialogCoordinatorTypeMock()
        trackingProvider = TrackingTypeMock()
        appConfiguration = ConfigurationMock(appVariant: .wissen)
        storage = MemoryStorage()
        remoteConfigRepository = RemoteConfigRepositoryTypeMock()
        consentApplicationService = ConsentApplicationServiceTypeMock()

        startupDialogPresenter = StartupDialogPresenter(coordinator: startupDialogCoordinator,
                                                        consentApplicationService: consentApplicationService,
                                                        trackingProvider: trackingProvider,
                                                        storage: storage,
                                                        appConfiguration: appConfiguration,
                                                        remoteConfigRepository: remoteConfigRepository)
    }

    func testThatThePresenterAsksConsentServiceToShowCosentDialogIfNeededWhenItIsStarted() {
        XCTAssertEqual(consentApplicationService.showConsentDialogIfNeededCallCount, 0)

        startupDialogPresenter.showFirstDialog()

        XCTAssertEqual(consentApplicationService.showConsentDialogIfNeededCallCount, 1)
    }
}
