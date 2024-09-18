//
//  AppToWebPresenterTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 04.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import Networking
import XCTest

class AppToWebPresenterTests: XCTestCase {

    var presenter: AppToWebPresenter!
    var authenticationClient: AuthenticationClientMock!
    var configuration: ConfigurationMock!

    override func setUp() {
        authenticationClient = AuthenticationClientMock()
        configuration = ConfigurationMock()
        presenter = AppToWebPresenter(authenticationClient: authenticationClient, appConfiguration: configuration, lastPathComponent: .fixture(), queryParameters: [:])
    }

    func testThatTheUrlIsSentToTheViewIncludingTheOneTimeTokenWhenTheClientSuccessfullyIssuesIt() {
        let exp = expectation(description: "loadRequest was called on the view")
        let token: String = .fixture()
        let view = WebViewControllerTypeMock()

        authenticationClient.issueOneTimeTokenHandler = { _, completion in
            completion(.success(OneTimeToken(token: token)))
        }

        view.loadRequestHandler = { urlRequest in
            XCTAssertEqual(urlRequest.url?.queryItem(forName: "token")?.value, token)
            exp.fulfill()
        }

        presenter.view = view

        wait(for: [exp], timeout: 0.1)
    }

    func testThatTheUrlIsSentToTheViewEvenWhenTheClientFailsToIssueTheToken() {
        let exp = expectation(description: "loadRequest was called on the view")

        authenticationClient.issueOneTimeTokenHandler = { _, completion in
            completion(.failure(NetworkError<EmptyAPIError>.other(.fixture())))
        }

        let view = WebViewControllerTypeMock()
        view.loadRequestHandler = { _ in
            exp.fulfill()
        }

        presenter.view = view

        wait(for: [exp], timeout: 0.1)
    }
}
