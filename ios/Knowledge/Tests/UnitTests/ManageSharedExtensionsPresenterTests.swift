//
//  ManageSharedExtensionsPresenterTests.swift
//  KnowledgeTests
//
//  Created by Mohamed Abdul Hameed on 10.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import Networking
import XCTest

class ManageSharedExtensionsPresenterTests: XCTestCase {

    var presenter: ManageSharedExtensionsPresenterType!
    var authenticationClient: AuthenticationClientMock!
    var repository: SharedExtensionRepositoryTypeMock!
    var configuration: ConfigurationMock!

    override func setUp() {
        authenticationClient = AuthenticationClientMock()
        repository = SharedExtensionRepositoryTypeMock()
        configuration = ConfigurationMock()
        presenter = ManageSharedExtensionsPresenter(authenticationClient: authenticationClient, appConfiguration: configuration, sharedExtensionsRepository: repository)
    }

    func testThatTheLoadingStateIsSetToTheView() {
        let view = WebViewControllerTypeMock()
        view.setIsLoadingHandler = { isLoading in
            XCTAssertTrue(isLoading)
        }
        presenter.view = view
        XCTAssertEqual(view.setIsLoadingCallCount, 1)
    }

    func testThatUrlFetchingErrorsAreSentToTheView() {
        let view = WebViewControllerTypeMock()
        presenter.view = view

        presenter.failedToLoad(with: UnknownError.unknown)

        XCTAssertEqual(view.showErrorCallCount, 1)
    }

    func testThatTheUrlIsSentToTheViewIncludingTheTokenWhenTheClientSuccessfullyIssuesTheToken() {
        let exp = expectation(description: "loadRequest was called on the view")
        let token = String.fixture()
        authenticationClient.issueOneTimeTokenHandler = { _, completion in
            completion(.success(OneTimeToken(token: token)))
        }
        let view = WebViewControllerTypeMock()
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
