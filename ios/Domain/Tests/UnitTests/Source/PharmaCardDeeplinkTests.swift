//
//  PharmaCardDeeplinkTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 03.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

// swiftlint:disable force_unwrapping

@testable import Domain
import XCTest

class PharmaCardDeeplinkTests: XCTestCase {

    // New link style ...

    func testCorrectNewPharmaCardDeeplinksWithMinimalInformation() throws {
        let url = "https://next.amboss.com/de/pharma/1290?"
        let deeplink = PharmaCardDeeplink(url: URL(string: url)!)
        XCTAssertNotNil(deeplink, "Link \(url) is correct pharma card deep link.")
        XCTAssertEqual(deeplink?.substance.value, "1290")
        XCTAssertNil(deeplink?.drug)
        XCTAssertNil(deeplink?.document)
    }

    func testCorrectNewPharmaCardDeeplinksWithPocketCardDocumentQuery() throws {
        let url = "https://next.amboss.com/de/pharma/1290?document=pocket_card&pc_group=adult"
        let deeplink = PharmaCardDeeplink(url: URL(string: url)!)
        XCTAssertNotNil(deeplink, "Link \(url) is correct pharma card deep link.")
        XCTAssertEqual(deeplink?.substance.value, "1290")
        switch try XCTUnwrap(deeplink?.document) {
        case .ifap:
            XCTFail("Document should be pocket card")
        case .pocketCard(let group, let anchor):
            XCTAssertEqual(group, "adult")
            XCTAssertNil(anchor)
        }
    }

    func testCorrectNewPharmaCardDeeplinksWithDrugAndGroupQueryAndPocketCardAnchor() throws {
        let url = "https://next.amboss.com/de/pharma/1290?drug_id=1218850&pc_group=adult#pocketcard"
        let deeplink = PharmaCardDeeplink(url: URL(string: url)!)
        XCTAssertNotNil(deeplink, "Link \(url) is correct pharma card deep link.")
        XCTAssertEqual(deeplink?.substance.value, "1290")
        XCTAssertEqual(deeplink?.drug?.value, "1218850")
        switch try XCTUnwrap(deeplink?.document) {
        case .ifap:
            XCTFail("Document should be pocket card")
        case .pocketCard(let group, let anchor):
            XCTAssertEqual(group, "adult")
            XCTAssertNil(anchor)
        }
    }

    func testCorrectNewPharmaCardDeeplinksWithDocumentAndGroupQueryAndAnchor() throws {
        let url = "https://next.amboss.com/de/pharma/1290?document=pocket_card&pc_group=adult#pc_dani"
        let deeplink = PharmaCardDeeplink(url: URL(string: url)!)
        XCTAssertNotNil(deeplink, "Link \(url) is correct pharma card deep link.")
        XCTAssertEqual(deeplink?.substance.value, "1290")
        switch try XCTUnwrap(deeplink?.document) {
        case .ifap:
            XCTFail("Document should be pocket card")
        case .pocketCard(let group, let anchor):
            XCTAssertEqual(group, "adult")
            XCTAssertEqual(anchor, "pc_dani")
        }
    }

    func testCorrectNewPharmaCardDeeplinksWithDrugSelectorFragment() throws {
        let url = "https://next.amboss.com/de/pharma/123?drug_id=456&pc_group=adult#ifap_drug_selector"
        let deeplink = PharmaCardDeeplink(url: URL(string: url)!)
        XCTAssertNotNil(deeplink, "Link \(url) is correct pharma card deep link.")
        XCTAssertEqual(deeplink?.substance.value, "123")
        XCTAssertEqual(deeplink?.drug?.value, "456")
        switch try XCTUnwrap(deeplink?.document) {
        case .ifap(let presentation):
            switch presentation {
            case .drugSelector: break
            default: XCTFail("presentation should be .drugSelector")
            }
        case .pocketCard: XCTFail("Document should be .ifap")
        }
    }

    // Old link style (still supported) ...

    func testIncorrectPharmaCardDeepLink() {
        let links: [String] = [
            "http://amboss.com",
            "https://www.amboss.com/de/home-studientelegramm"
        ]

        for link in links {
            XCTAssertNil(PharmaCardDeeplink(url: URL(string: link)!), "Link \(link) should be incorrect.")
        }
    }

    func testCorrectPharmaCardDeeplinks() {
        let url = "https://next.amboss.com/de/pharma/e1d7a2d385665ddbe2a2dc5e7571bf82/1097970"

        let deeplink = PharmaCardDeeplink(url: URL(string: url)!)

        XCTAssertNotNil(deeplink, "Link \(url) is correct pharma card deep link.")
        XCTAssertEqual(deeplink?.substance.value, "e1d7a2d385665ddbe2a2dc5e7571bf82")
        XCTAssertEqual(deeplink?.drug?.value, "1097970")
    }

    func testCorrectPharmaCardDeeplinkWithQuery() {
        let url = "https://next.amboss.com/de/pharma/f331c33bffe2327a07d5940768e30747/1467007?q=alcon"

        let deeplink = PharmaCardDeeplink(url: URL(string: url)!)

        XCTAssertNotNil(deeplink, "Link \(url) is correct pharma card deep link.")
        XCTAssertEqual(deeplink?.substance.value, "f331c33bffe2327a07d5940768e30747")
        XCTAssertEqual(deeplink?.drug?.value, "1467007")
    }

    func testPharmaLinksWithEightCharcterDrugId() {
        let url = "https://next.amboss.com/de/pharma/7f0cf7e5800d9b78026d6aedf0733a4b/13335771?q=sele"

        let deeplink = PharmaCardDeeplink(url: URL(string: url)!)

        XCTAssertNotNil(deeplink, "Link \(url) is correct pharma card deep link.")
        XCTAssertEqual(deeplink?.substance.value, "7f0cf7e5800d9b78026d6aedf0733a4b")
        XCTAssertEqual(deeplink?.drug?.value, "13335771")
    }
}
