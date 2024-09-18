//
//  AmbossBundleHandlerTests.swift
//  KnowledgeTests
//
//  Created by Roberto Seidenberg on 01.11.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
@testable import Knowledge_DE
import WebKit
import XCTest

class BundleSchemeHandlerTests: XCTestCase {

    var handler: CommonBundleSchemeHandler!
    let webView = WKWebView(frame: .zero)
    let bundle = Bundle.tests

    override func setUp() {
        handler = CommonBundleSchemeHandler()
    }

    // MARK: Files from bundle

    func testThat_theBundleReturnsExpectedData_givenAValidURL() throws {
        let file = "Lato-Regular.ttf"
        let commonBundle = Bundle(for: Common.EmptyClass.self)
        let data = try Data(contentsOf: commonBundle.url(forResource: file, withExtension: nil)!)
        let url = try XCTUnwrap(CommonBundleSchemeHandler.url(for: file))
        let request = URLRequest(url: url)
        let task = TestSchemeTask(request: request)

        task.responseHandler = { response in
            XCTAssertEqual(response.url, url)
        }

        task.dataHandler = { dta in
            XCTAssertEqual(dta, data)
        }

        handler.webView(webView, start: task)
    }
}
