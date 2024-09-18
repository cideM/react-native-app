//
//  SearchDeeplinkTests.swift
//  InterfacesTests
//
//  Created by Cornelius Horstmann on 07.11.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

// swiftlint:disable force_unwrapping

@testable import Domain
import XCTest

class SearchDeeplinkTests: XCTestCase {

    func testThatAnyKindOfDeeplinkWithAQueryIsntParsed() {
        let webpageURL = URL(string: "https://next.amboss.com/de/random?q=ramipril&v=overview")!
        let deepLink = SearchDeeplink(url: webpageURL)
        XCTAssertNil(deepLink)
    }

    func testThatSearchDeeplinksAreCorrectlyParsed() {
        let cases: [String: SearchDeeplink] = [
            "https://next.amboss.com/us/search/Chest%20pain": SearchDeeplink(type: .all, query: "Chest pain"),
            "https://next.amboss.com/de/search/Pertussis": SearchDeeplink(type: .all, query: "Pertussis"),
             "https://next.amboss.com/de/search/ramipril?q=ramipril1&v=pharma": SearchDeeplink(type: .pharma, query: "ramipril"),
            "https://next.amboss.com/de/search?q=ramipril2&v=pharma": SearchDeeplink(type: .pharma, query: "ramipril2"),
            "https://next.amboss.com/us/search?q=ramipril3&v=pharma": SearchDeeplink(type: .pharma, query: "ramipril3"),
            "https://next.amboss.com/de/search?q=ramipril4&v=overview": SearchDeeplink(type: .all, query: "ramipril4"),
            "https://next.amboss.com/de/search?q=ramipril5&v=article": SearchDeeplink(type: .article, query: "ramipril5"),
            "https://next.amboss.com/de/search?q=ramipril6&v=guideline": SearchDeeplink(type: .guideline, query: "ramipril6"),
            "https://next.amboss.com/de/search?q=ramipril7&v=media": SearchDeeplink(type: .media, query: "ramipril7"),
            "https://next.amboss.com/de/search?q=lungs&v=media&mtype=microscopy": SearchDeeplink(type: .media, query: "lungs", filter: "microscopy"),
            "https://next.amboss.com/de/search?q=lungenembolie&v=media&mtype=imaging&mtype=chart": SearchDeeplink(type: .media, query: "lungenembolie", filter: "imaging")
        ]
        for (url, expected) in cases {
            let deeplink = SearchDeeplink(url: URL(string: url)!)
            XCTAssertEqual(deeplink, expected)
        }
    }

}
