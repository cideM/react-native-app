//
//  DeeplinkTests.swift
//  KnowledgeTests
//
//  Created by Vedran Burojevic on 10/09/2020.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

// swiftlint:disable force_unwrapping

@testable import Domain
import XCTest

class DeeplinkTests: XCTestCase {

    func testThatDeeplinkFromUrlFallsBackToUnsupported() {
        let webpageURL = URL(string: "random-string")!
        XCTAssertEqual(Deeplink(url: webpageURL), .unsupported(webpageURL))
    }

    func testDeeplinkCreatedSuccessfullyFromLearningCardLink() {
        let webpageURL = URL(string: "https://www.amboss.com/de/library#xid=bH0HKh&anker=Zf974d8cff01b469f038157cfd85da31c")!
        XCTAssertEqual(Deeplink(url: webpageURL), .learningCard(LearningCardDeeplink(learningCard: "bH0HKh", anchor: "Zf974d8cff01b469f038157cfd85da31c", sourceAnchor: nil, question: nil)))
    }

    func testDeeplinkCreatedFromPharmaLink() {
        // Legacy link ...
        let webpageURL1 = URL(string: "https://next.amboss.com/de/pharma/e1d7a2d385665ddbe2a2dc5e7571bf82/1097970")!
        XCTAssertEqual(Deeplink(url: webpageURL1), .pharmaCard(PharmaCardDeeplink(substance: "e1d7a2d385665ddbe2a2dc5e7571bf82", drug: "1097970")))

        // Legacy link ...
        let webpageURL2 = URL(string: "https://next.amboss.com/de/pharma/e1d7a2d385665ddbe2a2dc5e7571bf82/1097941?q=Ramipril")!
        XCTAssertEqual(Deeplink(url: webpageURL2), .pharmaCard(PharmaCardDeeplink(substance: "e1d7a2d385665ddbe2a2dc5e7571bf82", drug: "1097941")))

        // Contemporary link ...
        let webpageURL3 = URL(string: "https://next.amboss.com/de/pharma/e1d7a2d385665ddbe2a2dc5e7571bf82/377801?q=Ramipril")!
        XCTAssertEqual(Deeplink(url: webpageURL3), .pharmaCard(PharmaCardDeeplink(substance: "e1d7a2d385665ddbe2a2dc5e7571bf82", drug: "377801")))

        // Contemporary link ...
        let webpageURL4 = URL(string: "https://next.amboss.com/de/pharma/50ec6ab26e195143100c7f97fa57602d/854045?q=apixaban")!
        XCTAssertEqual(Deeplink(url: webpageURL4), .pharmaCard(PharmaCardDeeplink(substance: "50ec6ab26e195143100c7f97fa57602d", drug: "854045")))

        // Imaginary link in order to make sure that the parsing does not depend on character counts ...
        let webpageURL5 = URL(string: "https://next.amboss.com/de/pharma/abcd/100?q=apixaban")!
        XCTAssertEqual(Deeplink(url: webpageURL5), .pharmaCard(PharmaCardDeeplink(substance: "abcd", drug: "100")))
    }

    func testDeeplinkCreatedFromMonographLink() {
        let webpageURL = URL(string: "https://next.amboss.com/us/pharma/metreleptin#warnings")!
        XCTAssertEqual(Deeplink(url: webpageURL), .monograph(MonographDeeplink(monograph: "metreleptin", anchor: "warnings", query: nil)))
    }

    func testDeeplinkCreatedFromLoginLink() {
        let webpageURL = URL(string: "https://www.amboss.com/de/app/wissen/login")!
        XCTAssertEqual(Deeplink(url: webpageURL), .login(LoginDeeplink()))
    }

    func testDeeplinkCreatedFromSearchLink() {
        let webpageURL = URL(string: "https://next.amboss.com/de/search?q=ramipril6&v=guideline")!
        XCTAssertEqual(Deeplink(url: webpageURL), .search(SearchDeeplink(type: .guideline, query: "ramipril6")))
    }

    func testUnsuccessfulCreationOfLearningCardDeepLinkFromAnInvalidLibraryLink() {
        let webpageURL = URL(string: "https://www.amboss.com/de/library#wrong=bH0HKh&link=Zf974d8cff01b469f038157cfd85da31c")!
        XCTAssertEqual(Deeplink(url: webpageURL), .unsupported(webpageURL))
    }

    func testDeepLinkCreatedUnsuccessfullyFromWrongLink() {
        let webpageURL = URL(string: "https://www.amboss.com")!
        XCTAssertEqual(Deeplink(url: webpageURL), .unsupported(webpageURL))
    }
}
