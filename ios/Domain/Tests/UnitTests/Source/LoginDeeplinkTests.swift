//
//  LoginDeeplinkTests.swift
//  InterfacesTests
//
//  Created by Cornelius Horstmann on 10.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

// swiftlint:disable force_unwrapping

@testable import Domain
import XCTest

class LoginDeeplinkTests: XCTestCase {

    func testThatSearchDeeplinksAreCorrectlyParsed() {
        let cases: [String: LoginDeeplink] = [
            "https://next.amboss.com/de/app/wissen/login": LoginDeeplink(),
            "https://next.amboss.com/app/wissen/login": LoginDeeplink(),
            "https://next.amboss.com/us/app/knowledge/login": LoginDeeplink(),
            "https://next.amboss.com/app/knowledge/login": LoginDeeplink()
        ]
        for (url, expected) in cases {
            let deeplink = LoginDeeplink(url: URL(string: url)!)
            XCTAssertEqual(deeplink, expected)
        }
    }

}
