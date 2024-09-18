//
//  WebViewPresenterTests.swift
//  KnowledgeTests
//
//  Created by Vedran Burojevic on 17.08.2020..
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
@testable import Knowledge_DE
import XCTest

class WebViewPresenterTests: XCTestCase {

    var webViewPresenter: WebViewPresenterType!
    var webViewController: WebViewControllerTypeMock!

    override func setUp() {
        webViewPresenter = WebViewPresenter(with: URL(string: "https://www.amboss.com")!)
        webViewController = WebViewControllerTypeMock()
        webViewPresenter.view = webViewController
    }

    func testThatThePresenterTellsViewToPresentAnErrorWhenTheRepositoryReturnsNil() {
        webViewPresenter.failedToLoad(with: NSError(domain: .fixture(), code: .fixture(), userInfo: nil))
        XCTAssertEqual(webViewController.showErrorCallCount, 1)
    }
}
