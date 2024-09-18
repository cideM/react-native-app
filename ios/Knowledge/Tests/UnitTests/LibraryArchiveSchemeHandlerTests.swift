//
//  AmbossSchemeHandlerTests.swift
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

class LibraryArchiveSchemeHandlerTests: XCTestCase {

    var handler: LibraryArchiveSchemeHandler!
    var library: LibraryTypeMock!
    var libraryRepository: LibraryRepositoryTypeMock!
    var client: LearningCardLibraryClientMock!

    let webView = WKWebView(frame: .zero)

    override func setUp() {
        library = LibraryTypeMock(metadata: .fixture())
        libraryRepository = LibraryRepositoryTypeMock(library: library, learningCardStack: PointableStack<LearningCardDeeplink>())

        client = LearningCardLibraryClientMock()
        handler = LibraryArchiveSchemeHandler(libraryRepository: libraryRepository, client: client)
    }

    // MARK: HTML body

//    func testThat_theClientWillNotGetCalled_ifTheLearningCardCouldBeFoundLocally() throws {
//
//        let expectation = expectation(description: "Metadata repository should be called")
//
//        let body = String.fixture()
//        library.learningCardHtmlBodyHandler = { _ in
//            expectation.fulfill()
//            return body
//        }
//
//        client.getLearningCardHtmlHandler = { _, _, _ in
//            XCTFail()
//        }
//
//        let request = URLRequest(url: LibraryArchiveSchemeHandler.url(for: .fixture()))
//        let task = TestSchemeTask(request: request)
//
//        handler.webView(webView, start: task)
//
//        wait(for: [expectation], timeout: 0.1)
//
//        XCTAssertEqual(library.learningCardHtmlBodyCallCount, 1)
//        XCTAssertEqual(client.getLearningCardHtmlCallCount, 0)
//    }
//
//    func testThat_theClientWillGetCalled_ifTheLearningCardCouldNotBeFoundLocally() throws {
//
//        let metadataExpectation = expectation(description: "Metadata repository should be called")
//        let clientExpectation = expectation(description: "Client should be called")
//
//        library.learningCardHtmlBodyHandler = { identifier in
//            metadataExpectation.fulfill()
//            throw LibraryError.missingLearningCard(identifier: identifier)
//        }
//
//        client.getLearningCardHtmlHandler = { _, _, completion in
//            clientExpectation.fulfill()
//            completion(.success(.fixture()))
//        }
//
//        let request = URLRequest(url: LibraryArchiveSchemeHandler.url(for: .fixture()))
//        let task = TestSchemeTask(request: request)
//
//        handler.webView(webView, start: task)
//
//        wait(for: [metadataExpectation, clientExpectation], timeout: 0.1)
//
//        XCTAssertEqual(library.learningCardHtmlBodyCallCount, 1)
//        XCTAssertEqual(client.getLearningCardHtmlCallCount, 1)
//    }
//
//    // MARK: Auxillary files (css, js ...)
//
//    func testThat_auxillaryFilesWillBeReadFromTheLocalLibrary() throws {
//
//        let dataExpectation = expectation(description: "Data should be queried")
//
//        let fragment = String.fixture()
//        library.dataHandler = { path in
//            dataExpectation.fulfill()
//            XCTAssert(path.hasSuffix(fragment))
//            return Data()
//        }
//
//        library.learningCardHtmlBodyHandler = { _ in
//            XCTFail()
//            return .fixture()
//        }
//
//        client.getLearningCardHtmlHandler = { _, _, _ in
//            XCTFail()
//        }
//
//        let url = LibraryArchiveSchemeHandler.baseUrl().appendingPathComponent(fragment, conformingTo: .url)
//        let request = URLRequest(url: url)
//        let task = TestSchemeTask(request: request)
//
//        handler.webView(webView, start: task)
//
//        wait(for: [dataExpectation], timeout: 0.1)
//
//        XCTAssertEqual(library.learningCardHtmlBodyCallCount, 0)
//        XCTAssertEqual(library.dataCallCount, 1)
//        XCTAssertEqual(client.getLearningCardHtmlCallCount, 0)
//    }
//
//    // MARK: Errors
//
//    func testThat_anErrorIsReturned_ifTheHtmlCouldNotBeFoundLocallyOrRemote() throws {
//
//        let repositoryExpectation = expectation(description: "Should return error instead of html")
//        let clientExpectation = expectation(description: "Should return html")
//        let errorExpectation = expectation(description: "Error should be returned")
//
//        library.learningCardHtmlBodyHandler = { identifier in
//            repositoryExpectation.fulfill()
//            throw LibraryError.missingLearningCard(identifier: identifier)
//        }
//
//        client.getLearningCardHtmlHandler = { _, _, completion in
//            clientExpectation.fulfill()
//            completion(.failure(.failed(code: .fixture())))
//        }
//
//        let request = URLRequest(url: LibraryArchiveSchemeHandler.url(for: .fixture()))
//        let task = TestSchemeTask(request: request)
//
//        var error: Error?
//        task.errorHandler = { err in
//            error = err
//            errorExpectation.fulfill()
//        }
//        handler.webView(webView, start: task)
//
//        wait(for: [repositoryExpectation, clientExpectation, errorExpectation], timeout: 0.1)
//
//        XCTAssertEqual(library.learningCardHtmlBodyCallCount, 1)
//        XCTAssertEqual(client.getLearningCardHtmlCallCount, 1)
//        XCTAssertNotNil(error)
//    }
//
//    func testThat_anErrorIsReturned_ifTheURLIsMalformed() {
//
//        let errorExpectation = expectation(description: "Should return error")
//
//        library.learningCardHtmlBodyHandler = { _ in
//            XCTFail("This should not be called")
//            return .fixture()
//        }
//
//        client.getLearningCardHtmlHandler = { _, _, _ in
//            XCTFail("This should not be called")
//        }
//
//        let request = URLRequest(url: URL.fixture())
//        let task = TestSchemeTask(request: request)
//
//        task.errorHandler = { error in
//            if case LibraryArchiveSchemeHandler.Error.malformedURL(let urlString) = error {
//                XCTAssertEqual(String(describing: request.url), urlString)
//                errorExpectation.fulfill()
//            } else {
//                XCTFail("Unexpected error type: \(String(describing: error))")
//            }
//        }
//
//        handler.webView(webView, start: task)
//        wait(for: [errorExpectation], timeout: 0.1)
//
//        XCTAssertEqual(library.learningCardHtmlBodyCallCount, 0)
//        XCTAssertEqual(client.getLearningCardHtmlCallCount, 0)
//    }
//
//    func testThat_anErrorIsReturned_ifAuxillaryFileDoesNotExist() throws {
//
//        let dataExpectation = expectation(description: "Data should be queried")
//
//        let fragment = String.fixture()
//        let url = LibraryArchiveSchemeHandler.baseUrl().appendingPathComponent(fragment, conformingTo: .url)
//        let request = URLRequest(url: url)
//        let task = TestSchemeTask(request: request)
//
//        library.dataHandler = { _ in
//            dataExpectation.fulfill()
//            let underlyingError = NSError(domain: .fixture(), code: .fixture())
//            throw LibraryArchiveSchemeHandler.Error.fileMissing(path: url.path, underlyingError: underlyingError)
//        }
//
//        library.learningCardHtmlBodyHandler = { _ in
//            XCTFail("This should not be called")
//            return .fixture()
//        }
//
//        client.getLearningCardHtmlHandler = { _, _, _ in
//            XCTFail("This should not be called")
//        }
//
//        task.errorHandler = { error in
//            if case LibraryArchiveSchemeHandler.Error.fileMissing(let path, _) = error {
//                XCTAssert(path.hasSuffix(path))
//            } else {
//                XCTFail("Unexpected error type: \(String(describing: error))")
//            }
//        }
//
//        handler.webView(webView, start: task)
//        wait(for: [dataExpectation], timeout: 0.1)
//
//        XCTAssertEqual(library.learningCardHtmlBodyCallCount, 0)
//        XCTAssertEqual(library.dataCallCount, 1)
//        XCTAssertEqual(client.getLearningCardHtmlCallCount, 0)
//    }
}

// Reasons for subclassing this:
// * Can not be initialised otherwise (init is private)
// * Is required to inject tested URL into scheme handler
class TestSchemeTask: NSObject, WKURLSchemeTask {

    var request: URLRequest
    var responseHandler: ((URLResponse) -> Void)?
    var dataHandler: ((Data) -> Void)?
    var errorHandler: ((Error) -> Void)?

    init(request: URLRequest) {
        self.request = request
        super.init()
    }

    func didReceive(_ response: URLResponse) { responseHandler?(response) }
    func didReceive(_ data: Data) { dataHandler?(data) }
    func didFinish() {}
    func didFailWithError(_ error: Error) { errorHandler?(error) }
}
