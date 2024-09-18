//
//  MonographDeeplinkTests.swift
//  KnowledgeTests
//
//  Created by Manaf Alabd Alrahim on 03.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

// swiftlint:disable force_unwrapping

@testable import Domain
import XCTest

class MonographDeeplinkTests: XCTestCase {

    func testIncorrectMonographDeepLink() {
        let links: [String] = [
            "http://amboss.com",
            "https://www.amboss.com/de/home-studientelegramm",
            "https://next.amboss.com/de/pharma/e1d7a2d385665ddbe2a2dc5e7571bf82/1097970"
        ]

        for link in links {
            XCTAssertNil(MonographDeeplink(url: URL(string: link)!), "Link \(link) should be incorrect.")
        }
    }

    func testCorrectPharmaCardDeeplinks() {
        let url = "https://next.amboss.com/us/pharma/betamethasone-systemic"
        let deeplink = MonographDeeplink(url: URL(string: url)!)

        XCTAssertNotNil(deeplink, "Link \(url) is correct monograph deep link.")
        XCTAssertEqual(deeplink?.monograph.value, "betamethasone-systemic")
        XCTAssertEqual(deeplink?.anchor, nil)
    }

    func testCorrectPharmaCardDeeplinkWithQuery() {
        let url = "https://next.amboss.com/us/pharma/metreleptin?q=rami"
        let deeplink = MonographDeeplink(url: URL(string: url)!)

        XCTAssertNotNil(deeplink, "Link \(url) is correct agent deep link.")
        XCTAssertEqual(deeplink?.monograph.value, "metreleptin")
        XCTAssertEqual(deeplink?.anchor, nil)
    }

    func testCorrectPharmaCardDeeplinkWithAnchor() {
        let url = "https://next.amboss.com/us/pharma/metreleptin#warnings"
        let deeplink = MonographDeeplink(url: URL(string: url)!)

        XCTAssertNotNil(deeplink, "Link \(url) is correct agent deep link.")
        XCTAssertEqual(deeplink?.monograph.value, "metreleptin")
        XCTAssertEqual(deeplink?.anchor?.value, "warnings")
    }

    func testCorrectPharmaCardDeeplinkWithQueryAndAnchor() {
        let url = "https://next.amboss.com/us/pharma/metreleptin?ahfs_section=cauts,warn-precaut#warnings"
        let deeplink = MonographDeeplink(url: URL(string: url)!)

        XCTAssertNotNil(deeplink, "Link \(url) is correct agent deep link.")
        XCTAssertEqual(deeplink?.monograph.value, "metreleptin")
        XCTAssertEqual(deeplink?.anchor?.value, "warnings")
        XCTAssertEqual(deeplink?.query, "ahfs_section=cauts,warn-precaut")
    }
}
