//
//  KillSwitchRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 25.08.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
@testable import Knowledge_DE
import XCTest

class KillSwitchRepositoryTests: XCTestCase {

    var killSwitchRepository: KillSwitchRepositoryType!
    var storage: Storage!
    var application: Application!
    var bundleIdentifier: String = .fixture()
    var deprecationStatusDidChangeObserver: NSObjectProtocol?

    override func setUp() {
        storage = MemoryStorage()
        application = Application(name: .fixture(), displayName: .fixture(), buildVersion: .fixture(), version: "2.0.0", bundleIdentifier: bundleIdentifier)
        killSwitchRepository = KillSwitchRepository(storage: storage, application: application)
    }

    func testThatTheDefaultValueForDeprecationStatusIsNotDeprecated() {
        storage.store(nil as KillSwitchDeprecationStatus?, for: .deprecationStatus)

        XCTAssertEqual(killSwitchRepository.deprecationStatus, .notDeprecated)
    }

    func testThatCallingUpdateDeprecationStatusStoresTheNewStatus() {
        storage.store(nil as KillSwitchDeprecationStatus?, for: .deprecationStatus)

        _ = killSwitchRepository.updateDeprecationStatus(with: [.fixture()])

        let storedDeprecationStatus: KillSwitchDeprecationStatus? = storage.get(for: .deprecationStatus)
        XCTAssertNotNil(storedDeprecationStatus)
    }

    func testThatCallingUpdateDeprecationStatusWithADeprecatedItemStoresDeprecatedAsTheDeprecationStatus() {
        storage.store(nil as KillSwitchDeprecationStatus?, for: .deprecationStatus)
        let deprecationUrl: URL = .fixture()

        _ = killSwitchRepository.updateDeprecationStatus(with: [
            .fixture(minVersion: "1.0.0", maxVersion: "3.0.0", type: .unsupported, platform: .ios, identifier: bundleIdentifier, url: deprecationUrl)
        ])

        switch killSwitchRepository.deprecationStatus {
        case .notDeprecated:
            XCTFail("Should be deprecated")
        case .deprecated(let url):
            XCTAssertEqual(deprecationUrl, url, "URL does not match the deprecation URL")
        }
    }

    func testThatCallingUpdateDeprecationStatusWithDeprecatedInfoButDifferentPlatformStoresNotDeprecatedAsTheDeprecationStatus() {
        storage.store(nil as KillSwitchDeprecationStatus?, for: .deprecationStatus)
        let deprecationUrl: URL = .fixture()

        _ = killSwitchRepository.updateDeprecationStatus(with: [
            .fixture(minVersion: "1.0.0", maxVersion: "3.0.0", type: .unsupported, platform: .android, identifier: bundleIdentifier, url: deprecationUrl)
        ])

        switch killSwitchRepository.deprecationStatus {
        case .notDeprecated: break
        case .deprecated:
            XCTFail("Should not mark the version as deprecated because the platform does not match")
        }
    }

    func testThatCallingUpdateDeprecationStatusWithDeprecatedInfoButDifferentBundleIdentifierStoresNotDeprecatedAsTheDeprecationStatus() {
        storage.store(nil as KillSwitchDeprecationStatus?, for: .deprecationStatus)
        let deprecationUrl: URL = .fixture()

        _ = killSwitchRepository.updateDeprecationStatus(with: [
            .fixture(minVersion: "1.0.0", maxVersion: "3.0.0", type: .unsupported, platform: .ios, identifier: .fixture(), url: deprecationUrl)
        ])

        switch killSwitchRepository.deprecationStatus {
        case .notDeprecated: break
        case .deprecated:
            XCTFail("Should not mark the version as deprecated because the bundle identifier does not match")
        }
    }

    func testThatCallingUpdateDeprecationStatusWithDeprecatedInfoButUnmatchingVersionRangeStoresNotDeprecatedAsTheDeprecationStatus() {
        storage.store(nil as KillSwitchDeprecationStatus?, for: .deprecationStatus)
        let deprecationUrl: URL = .fixture()

        _ = killSwitchRepository.updateDeprecationStatus(with: [
            .fixture(minVersion: "1.0.0", maxVersion: "1.9.0", type: .unsupported, platform: .ios, identifier: bundleIdentifier, url: deprecationUrl)
        ])

        switch killSwitchRepository.deprecationStatus {
        case .notDeprecated: break
        case .deprecated:
            XCTFail("Should not mark the version as deprecated because the version does not fall in the deprecation range")
        }
    }

    func testThatCallingUpdateDeprecationStatusWithInfoThatWillChangeTheDeprecationStatusReturnsTrue() {
        storage.store(nil as KillSwitchDeprecationStatus?, for: .deprecationStatus)
        let deprecationUrl: URL = .fixture()

        let didChangeStoredDeprecationStatus = killSwitchRepository.updateDeprecationStatus(with: [
            .fixture(minVersion: "1.0.0", maxVersion: "3.0.0", type: .unsupported, platform: .ios, identifier: .fixture(), url: deprecationUrl)
        ])

        XCTAssertTrue(didChangeStoredDeprecationStatus, "Previously stored deprecation is nil ==> notDeprecated. The newly stored one is deprecated so a change happen and the method should return true")
    }

    func testThatUpdatingDeprecationStatusValueTriggersANotification() {
        storage.store(nil as KillSwitchDeprecationStatus?, for: .deprecationStatus)
        let deprecationUrl: URL = .fixture()

        let exp = expectation(description: "Notification received")
        deprecationStatusDidChangeObserver = NotificationCenter.default.observe(for: KillSwitchDeprecationStatusDidChangeNotification.self, object: killSwitchRepository, queue: .main) { _ in
            exp.fulfill()
        }

        _ = killSwitchRepository.updateDeprecationStatus(with: [
            .fixture(minVersion: "1.0.0", maxVersion: "3.0.0", type: .unsupported, platform: .ios, identifier: .fixture(), url: deprecationUrl)
        ])

        wait(for: [exp], timeout: 0.5)
    }
}
