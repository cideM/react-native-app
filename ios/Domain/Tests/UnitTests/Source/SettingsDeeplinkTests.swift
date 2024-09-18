//
//  SettingsDeeplinkTests.swift
//  DomainTests
//
//  Created by Roberto Seidenberg on 08.01.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

@testable import Domain
import XCTest

class SettingsDeeplinkTests: XCTestCase {

    func testThatAppearranceSettingsDeepinksAreCorrectlyParsed() throws {
        try [
            "https://next.amboss.com/de/settings/appearance",
            "https://next.amboss.com/us/settings/appearance"
        ].forEach {
            let url = try XCTUnwrap(URL(string: $0))
            XCTAssertEqual(Deeplink(url: url), .settings(SettingsDeeplink(screen: .appearance)))
        }

        try [
            "https://next.amboss.com/app/wissen/settings/appearance",
            "https://next.amboss.com/app/knowledge/settings/appearance"
        ].forEach {
            let url = try XCTUnwrap(URL(string: $0))
            XCTAssertEqual(Deeplink(url: url), .unsupported(url))
        }
    }
}
