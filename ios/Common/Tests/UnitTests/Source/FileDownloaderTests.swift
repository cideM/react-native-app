//
//  FileDownloaderTests.swift
//  KnowledgeTests
//
//  Created by Merve Kavaklioglu on 31.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

@testable import Common
import FixtureFactory
import Foundation
import OHHTTPStubs
import OHHTTPStubsSwift
import XCTest

class FileDownloaderTests: XCTestCase {

    var workingDirectory: URL!
    var downloader: FileDownloader!

    override func setUp() {
        super.setUp()

        // just to be doubly sure that the HTTPStub is loaded before we instantiate the downloaders urlsession
        HTTPStubs.setEnabled(true)
        workingDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("FileDownloaderTestsWorkingDirectory")
        downloader = try! FileDownloader(workingDirectory: workingDirectory)
    }

    override func tearDown() {
        super.tearDown()
        HTTPStubs.removeAllStubs()
    }

    func testThatDownloaderFailsIfTheDownloadFails() {
        let source = URL.fixture()
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("downloadedFile.zip")

        stub(condition: isAbsoluteURLString(source.absoluteString)) { _ in
            HTTPStubsResponse(error: NSError(domain: .fixture(), code: .fixture(), userInfo: nil))
        }

        let expectation = self.expectation(description: "completion called")

        downloader.download(from: source, to: destination) { _ in } completion: { result in
            switch result {
            case .success: XCTFail("Result should be a failure")
            case .failure(let error):
                switch error {
                case .network: break
                default:
                    XCTFail("Failure error type should be network, found: \(error)")
                }
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        try? FileManager.default.removeItem(at: destination)
    }

    func testThatDownloaderSucceedsIfTheDownloadSucceeds() {
        let source = URL.fixture()
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("downloadedFile.zip")

        stub(condition: isAbsoluteURLString(source.absoluteString)) { _ in
            let data = Data([1, 2, 3])
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/octet-stream"])
        }

        let expectation = self.expectation(description: "completion called")

        downloader.download(from: source, to: destination) { _ in } completion: { result in
            switch result {
            case .success: break
            case .failure: XCTFail("Result should be a sucess")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        try? FileManager.default.removeItem(at: destination)
    }

    func testThatDownloaderWritesTheResultToTheDestiationPath() {
        let source = URL.fixture()
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("downloadedFile.zip")
        let expectedData = String.fixture().data(using: .utf8)! // swiftlint:disable:this force_unwrapping

        stub(condition: isAbsoluteURLString(source.absoluteString)) { _ in
            HTTPStubsResponse(data: expectedData, statusCode: 200, headers: ["Content-Type": "application/octet-stream"])
        }

        let expectation = self.expectation(description: "completion called")

        downloader.download(from: source, to: destination) { _ in } completion: { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        XCTAssertTrue(FileManager.default.fileExists(atPath: destination.path))
        XCTAssertEqual(try Data(contentsOf: destination), expectedData)
        try? FileManager.default.removeItem(at: destination)
    }

    func testThatItFailsIfTheDestinationExists() {
        let source = URL.fixture()
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("downloadedFile.zip")
        FileManager.default.createFile(atPath: destination.path, contents: Data([1, 2, 3]), attributes: nil)

        stub(condition: isAbsoluteURLString(source.absoluteString)) { _ in
            let data = Data([1, 2, 3])
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/octet-stream"])
        }

        let expectation = self.expectation(description: "completion called")

        downloader.download(from: source, to: destination) { _ in } completion: { result in
            switch result {
            case .success: XCTFail("Result should be a failure")
            case .failure(let error):
                switch error {
                case .fileWithTheSameNameExistsInTheDestination: break
                default:
                    XCTFail("Failure error type should be fileWithTheSameNameExistsInTheDestination, found: \(error)")
                }
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        try? FileManager.default.removeItem(at: destination)
    }

    func testThatResumeDataIsDeletedAfterSuccess() {
        let source = URL.fixture()
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("downloadedFile.zip")
        let resumeDataURL = workingDirectory.appendingPathComponent(destination.lastPathComponent + "_resumeData")
        FileManager.default.createFile(atPath: resumeDataURL.path, contents: Data([1, 2, 3]), attributes: nil)

        stub(condition: isAbsoluteURLString(source.absoluteString)) { _ in
            let data = Data([1, 2, 3])
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/octet-stream"])
        }

        let expectation = self.expectation(description: "completion called")

        downloader.download(from: source, to: destination) { _ in } completion: { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
        try? FileManager.default.removeItem(at: destination)
        try? FileManager.default.removeItem(at: resumeDataURL)
    }

    func testThatTheProgressClosureIsCalled() {
        let source = URL.fixture()
        let destination = FileManager.default.temporaryDirectory.appendingPathComponent("downloadedFile.zip")

        stub(condition: isAbsoluteURLString(source.absoluteString)) { _ in
            let data = Data([1, 2, 3])
            return HTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/octet-stream"])
        }

        let expectation = self.expectation(description: "progress closure called")

        downloader.download(from: source, to: destination) { _ in expectation.fulfill() } completion: { _ in try? FileManager.default.removeItem(at: destination) }

        wait(for: [expectation], timeout: 5)
    }
}
