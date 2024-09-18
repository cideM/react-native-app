//
//  ShortcutsServiceTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 21.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

class ShortcutsServiceTests: XCTestCase {
    var configuration: ConfigurationMock!
    var shortcutsService: ShortcutsService!

    override func setUp() {
        configuration = ConfigurationMock()
        shortcutsService = ShortcutsService(appConfiguration: configuration)
    }

    func testThatAskingTheServiceForTheDeepLinkOfASupportedActivityTypeReturnsTheRightDeepLink() {
        let searchActivityType: String = .fixture()
        configuration.searchActivityType = searchActivityType

        let deepLink = shortcutsService.deepLink(for: NSUserActivity(activityType: searchActivityType))

        XCTAssertEqual(deepLink, .search(nil, source: .siri))
    }

    func testThatAskingTheServiceForTheDeepLinkOfAnUnsupportedActivityTypeReturnsNil() {
        configuration.searchActivityType = "supportedActivityType"
        let unsupportedActivityType = "unsupportedActivityType"

        let deepLink = shortcutsService.deepLink(for: NSUserActivity(activityType: unsupportedActivityType))

        XCTAssertNil(deepLink)
    }

    func testThatAskingUserActivityOfSupportedTypeReturnsUserActivityOfThatType() {
        let searchActivityType: String = .fixture()
        configuration.searchActivityType = searchActivityType

        let userActivity = shortcutsService.userActivity(for: .search)

        XCTAssertEqual(userActivity.activityType, searchActivityType)
    }
}
