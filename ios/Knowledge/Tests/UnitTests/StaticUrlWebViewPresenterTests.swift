//
//  StaticUrlWebViewPresenterTests.swift
//  KnowledgeTests
//
//  Created by Cornelius Horstmann on 29.09.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class StaticUrlWebViewPresenterTests: XCTestCase {
    var presenter: StaticUrlWebViewPresenter!
    var url: URL!

    override func setUp() {
        url = .fixture()
        presenter = StaticUrlWebViewPresenter(with: url)
    }

    func testThatInitializationDoesntFail() {
        presenter = StaticUrlWebViewPresenter(with: .fixture())
    }

    func testThatLoadRequestIsCalledOnTheViewWhenSettingTheView() {
        let view = WebViewControllerTypeMock()

        let loadRequestExpectation = expectation(description: "loadRequest is called")
        view.loadRequestHandler = { request in
            XCTAssertEqual(request.url, self.url)
            loadRequestExpectation.fulfill()
        }

        presenter.view = view

        wait(for: [loadRequestExpectation], timeout: 0.1)
    }

    func testThatFailedToLoadWillCallShowErrorOnTheView() {
        let view = WebViewControllerTypeMock()
        presenter.view = view

        let showErrorExpectation = expectation(description: "showError is called")
        view.showErrorHandler = { _, _ in
            showErrorExpectation.fulfill()
        }

        let presentableMessage = PresentableMessage(title: .fixture(), description: .fixture(), logLevel: .info)
        presenter.failedToLoad(with: presentableMessage)

        wait(for: [showErrorExpectation], timeout: 0.1)
    }

    func testThatFailedToLoadWillCallShowErrorOnTheViewWithAnUnknownError() {
        let view = WebViewControllerTypeMock()
        presenter.view = view

        let showErrorExpectation = expectation(description: "showError is called")
        view.showErrorHandler = { _, _ in
            showErrorExpectation.fulfill()
        }

        let error: NSError = .fixture()
        presenter.failedToLoad(with: error)

        wait(for: [showErrorExpectation], timeout: 0.1)
    }

    func testThatTheRetryActionInitiatesALoadRequest() {
        let view = WebViewControllerTypeMock()
        presenter.view = view

        let loadRequestExpectation = expectation(description: "loadRequest is called")
        view.loadRequestHandler = { request in
            XCTAssertEqual(request.url, self.url)
            loadRequestExpectation.fulfill()
        }
        view.showErrorHandler = { _, actions in
            actions.first!.execute()
        }

        let presentableMessage = PresentableMessage(title: .fixture(), description: .fixture(), logLevel: .info)
        presenter.failedToLoad(with: presentableMessage)

        wait(for: [loadRequestExpectation], timeout: 0.1)
    }

}
