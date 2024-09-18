//
//  RemoteConfigRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Merve Kavaklioglu on 03.02.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Firebase
import FirebaseRemoteConfig
import Foundation
@testable import Knowledge_DE
import XCTest

class RemoteConfigRepositoryTests: XCTestCase {

    // MARK: - Subject under test
    var repository: RemoteConfigRepository!

    // MARK: - Subject dependencies
    var remoteConfig: RemoteConfigType!

    // MARK: - Test lifecyle
    override class func setUp() {
        FirebaseApp.configure()
    }

    override func setUp() {
        super.setUp()
        repository = RemoteConfigRepository(remoteConfig: RemoteConfigTypeMock(requestTimeout: 0, searchAdConfig: SearchAdConfig(enabled: true, position: 0, pharmaOpensToHide: 0, timeForResetDays: 0)))
        remoteConfig = FirebaseRemoteConfig()
    }

    func testRequestTimeoutReturnsExpectedDefaultValue() {
        // This is actually not testing the RemoteConfigRepository, but the RemoteConfig
        // XCTAssertEqual(repository.requestTimeout, 2.0)
    }

    func testThatMonographsAreAvailableInKnowledgeAppInCaseTheyAreEnabled() {
        let config = SearchAdConfig(enabled: true, position: 0, pharmaOpensToHide: 0, timeForResetDays: 0)
        let mock = RemoteConfigTypeMock(requestTimeout: 0, searchAdConfig: config, areMonographsEnabled: true)
        let repository = RemoteConfigRepository(remoteConfig: mock, appVariant: .knowledge)
        XCTAssertTrue(repository.areMonographsEnabled)
    }

    func testThatMonographsAreNotAvailableInKnowledgeAppInCaseTheyAreDisabled() {
        let config = SearchAdConfig(enabled: true, position: 0, pharmaOpensToHide: 0, timeForResetDays: 0)
        let mock = RemoteConfigTypeMock(requestTimeout: 0, searchAdConfig: config, areMonographsEnabled: false)
        let repository = RemoteConfigRepository(remoteConfig: mock, appVariant: .knowledge)
        XCTAssertFalse(repository.areMonographsEnabled)
    }

    func testThatMonographsAreNotAvailableInWisenAppInCaseTheyAreDisabled() {
        let config = SearchAdConfig(enabled: true, position: 0, pharmaOpensToHide: 0, timeForResetDays: 0)
        let mock = RemoteConfigTypeMock(requestTimeout: 0, searchAdConfig: config, areMonographsEnabled: false)
        let repository = RemoteConfigRepository(remoteConfig: mock, appVariant: .wissen)
        XCTAssertFalse(repository.areMonographsEnabled)
    }

    func testThatMonographsAreNotAvailableInWisenAppInCaseTheyAreEnabled() {
        let config = SearchAdConfig(enabled: true, position: 0, pharmaOpensToHide: 0, timeForResetDays: 0)
        let mock = RemoteConfigTypeMock(requestTimeout: 0, searchAdConfig: config, areMonographsEnabled: true)
        let repository = RemoteConfigRepository(remoteConfig: mock, appVariant: .wissen)
        XCTAssertFalse(repository.areMonographsEnabled)
    }

}
