//
//  PDFViewerPresenterTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 01.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import Networking
import PDFKit
import XCTest

class PDFViewerPresenterTests: XCTestCase {

    var presenter: PDFViewerPresenterType!
    var view: PDFViewerViewTypeMock!
    var PDFViewerCoordinator: PDFViewerCoordinatorTypeMock!
    var mediaClient: MediaClientMock!

    let url: URL = .fixture()
    let temporaryLocalFileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending(UUID().uuidString))

    override func setUp() {
        view = PDFViewerViewTypeMock()
        PDFViewerCoordinator = PDFViewerCoordinatorTypeMock()
        mediaClient = MediaClientMock()
        presenter = PDFViewerPresenter(coordinator: PDFViewerCoordinator, url: url, title: .fixture(), mediaClient: mediaClient, temporaryLocalFileURL: temporaryLocalFileURL)
    }

    func testThatOnViewDidSetTheCorrectDocumentIsLoadedIfItIsValid() {
        let validPdfUrl = Bundle.tests.url(forResource: "validPDF", withExtension: "pdf")!
        let validPdfData = try! Data(contentsOf: validPdfUrl)

        mediaClient.downloadDataHandler = { _, result in
            result(.success(validPdfData))
        }

        let exp = expectation(description: "DownloadDocument function is called")
        view.showDocumentHandler = { pdfDocument in
            XCTAssertEqual(PDFDocument(data: validPdfData)?.string, pdfDocument.string)
            exp.fulfill()
        }

        presenter.view = view
        wait(for: [exp], timeout: 0.1)
    }

    func testThatWhenTheClientFailsToLoadTheDocumentTheViewReflectsIt() {
        let noConnectionError = NetworkError<EmptyAPIError>.noInternetConnection

        mediaClient.downloadDataHandler = { _, result in
            result(.failure(noConnectionError))
        }

        let exp = expectation(description: "showError function is called")
        view.showErrorHandler = { error, _ in
            XCTAssertEqual(error.body, noConnectionError.body)
            exp.fulfill()
        }

        presenter.view = view
        wait(for: [exp], timeout: 0.1)
    }

    func testThatWhenTheClientSucceedsInLoadingTheDocumentButHasInvalidDataTheViewReflectsIt() {
        let invalidPdfUrl = Bundle.tests.url(forResource: "invalidPDF", withExtension: "pdf")!
        let invalidPdfData = try! Data(contentsOf: invalidPdfUrl)

        mediaClient.downloadDataHandler = { _, result in
            result(.success(invalidPdfData))
        }

        let exp = expectation(description: "showError function is called")
        view.showErrorHandler = { error, _ in
            XCTAssertEqual(error.body, PDFViewerError.pdfDocumentCouldNotBeConstructed.body)
            exp.fulfill()
        }

        presenter.view = view
        wait(for: [exp], timeout: 0.1)
    }

    func testThatWhenSharePDFIsCalledThePresenterCallsTheCoordinator() {
        let validPdfUrl = Bundle.tests.url(forResource: "validPDF", withExtension: "pdf")!
        let validPdfData = try! Data(contentsOf: validPdfUrl)

        mediaClient.downloadDataHandler = { _, result in
            result(.success(validPdfData))
        }

        let exp = expectation(description: "shareDocument function is called")
        PDFViewerCoordinator.shareDocumentHandler = {  _, _ in
            exp.fulfill()
        }

        presenter.view = view

        presenter.shareDocument()
        wait(for: [exp], timeout: 0.1)
    }

    func testThatWhenThePresenterIsDeinitializedThePDFDocumentIsRemovedFromFileSystem() {
        let validPdfUrl = Bundle.tests.url(forResource: "validPDF", withExtension: "pdf")!
        let validPdfData = try! Data(contentsOf: validPdfUrl)

        mediaClient.downloadDataHandler = { _, completion in
            completion(.success(validPdfData))
        }

        let expectation = self.expectation(description: "showDocument called")
        view.showDocumentHandler = { _ in
            expectation.fulfill()
        }
        presenter.view = view

        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: temporaryLocalFileURL.path))

        presenter = nil
        XCTAssertFalse(FileManager.default.fileExists(atPath: temporaryLocalFileURL.path))
    }
}
