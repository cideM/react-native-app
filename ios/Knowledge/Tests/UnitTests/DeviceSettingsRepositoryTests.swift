//
//  DeviceSettingsRepositoryTests.swift
//  KnowledgeTests
//
//  Created by Aamir Suhial Mir on 29.07.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//
@testable import Knowledge_DE
import XCTest

import Foundation
import Domain
import Networking

class DeviceSettingsRepositoryTests: XCTestCase {
    var repository: DeviceSettingsRepositoryType!
    var storage: MemoryStorage!

    override func setUp() {
        storage = MemoryStorage()

        repository = DeviceSettingsRepository(storage: storage)
    }

    func testThatWhenAuthorizationIsNilThenStorageDataIsReseted() {
        repository.currentFontScale = 1.6
        repository.keepScreenOn = false

        NotificationCenter.default.post(AuthorizationDidChangeNotification(oldValue: nil, newValue: nil), sender: self)

        XCTAssertEqual(repository.currentFontScale, 1.0)
        XCTAssertTrue(repository.keepScreenOn)
    }

    func testThatWhenAuthorizationIsNotNilThenStorageDataIsNotReseted() {
        let currentFontScale: Float = 0.4
        let keepScreenOn = false

        repository.currentFontScale = currentFontScale
        repository.keepScreenOn = keepScreenOn

        NotificationCenter.default.post(AuthorizationDidChangeNotification(oldValue: Authorization.fixture(), newValue: Authorization.fixture()), sender: self)

        XCTAssertEqual(repository.currentFontScale, currentFontScale)
        XCTAssertEqual(repository.keepScreenOn, keepScreenOn)
    }
}
