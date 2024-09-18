//
//  CouponCodeDeeplinkTests.swift
//  Domain
//
//  Created by Roberto Seidenberg on 22.01.24.
//  Copyright © 2024 AMBOSS GmbH. All rights reserved.
//

@testable import Domain
import XCTest

class ProductKeyDeeplinkTests: XCTestCase {

    func testThatTheUSKeyIsParsed() throws {
        try [
            "TESTC0DEF0RM0B11EAPPDEVE10PMENT",
            "ST8CVVM2YCNQ"
        ].forEach { code in
            let url = try XCTUnwrap(URL(string: "https://www.amboss.com/us/campuslicense/add?key=\(code)"))
            XCTAssertEqual(Deeplink(url: url), .productKey(.init(code: code)))
        }
    }

    func testThatTheDEKeyIsParsed() throws {
        try [
            "TESTC0DEF0RM0B11EAPPDEVE10PMENT",
            "ST8CVVM2YCNQ"
        ].forEach { code in
            let url = try XCTUnwrap(URL(string: "https://www.amboss.com/de/account/accessChooser?key=\(code)"))
            XCTAssertEqual(Deeplink(url: url), .productKey(.init(code: code)))
        }
    }

    func testThatKeylessLinksAreParsedAsUnsupported() throws {
        // This case should actually never happen since "codeless" links would directly open in the browser
        // as defined by the "apple-app-site-association" file
        try [
            "https://www.amboss.com/us/campuslicense/add",
            "https://www.amboss.com/de/account/accessChooser"
        ].forEach {
            let url = try XCTUnwrap(URL(string: $0))
            XCTAssertEqual(Deeplink(url: url), .unsupported(url))
        }
    }

    func testThatUSLinksWithDEFragmentArtNotParsed() throws {
        try [
            "https://www.amboss.com/de/campuslicense/add?key=TESTC0DEF0RM0B11EAPPDEVE10PMENT",
            "https://www.amboss.com/de/campuslicense/add"
        ].forEach {
            let url = try XCTUnwrap(URL(string: $0))
            XCTAssertEqual(Deeplink(url: url), .unsupported(url))
        }
    }

    func testThatDELinksWithUSFragmentArtNotParsed() throws {
        try [
            "https://www.amboss.com/us/account/accessChooser?key=TESTC0DEF0RM0B11EAPPDEVE10PMENT",
            "https://www.amboss.com/us/account/accessChooser"
        ].forEach {
            let url = try XCTUnwrap(URL(string: $0))
            XCTAssertEqual(Deeplink(url: url), .unsupported(url))
        }
    }
}
