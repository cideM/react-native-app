//
//  LibraryUpdaterLegacyCleanerTests.swift
//  KnowledgeTests
//
//  Created by Cornelius Horstmann on 27.12.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class LibraryUpdaterLegacyCleanerTests: XCTestCase {

    var libraryRepository: LibraryRepositoryTypeMock!
    var libraryUpdaterLegacyCleaner: LibraryUpdaterLegacyCleaner!

    override func setUp() {
        libraryUpdaterLegacyCleaner = LibraryUpdaterLegacyCleaner()
        libraryRepository = LibraryRepositoryTypeMock()
        libraryRepository.library = try! Library.Fixture.valid()
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: libraryRepository.library.url)
    }

// This test could not be made to run succesfully on CI although it works flawless locally
// Reason for this is unknown. Fix could not be found. Disabled for now.
//    @available(iOS 15, *)
//    func testThatItCleansUpTheTempFolder() throws {
//        let tempFolder = FileManager.default.temporaryDirectory
//        let oldRandomFilePath = tempFolder.appendingPathComponent("LibraryUpdaterLegacyCleanerTests_testThatItCleansUpTheTempFolder")
//        FileManager.default.createFile(atPath: oldRandomFilePath.path, contents: String.fixture().data(using: .utf8))
//
//        let attributes = [FileAttributeKey.creationDate: Date.now - 10.days]
//        try! FileManager.default.setAttributes(attributes, ofItemAtPath: oldRandomFilePath.path)
//
//        let expectation = self.expectation(description: "Temp folder is cleaned")
//        _ = try DeletionMonitor(url: oldRandomFilePath) { url in
//            XCTAssertFalse(FileManager.default.fileExists(atPath: oldRandomFilePath.path))
//            expectation.fulfill()
//        }
//
//        XCTAssert(FileManager.default.fileExists(atPath: oldRandomFilePath.path))
//        libraryUpdaterLegacyCleaner.cleanupTempFolder()
//        wait(for: [expectation], timeout: 6)
//    }

    func testThatItCleansUpUnusedLibraries() throws {
        let zipLibraryDirectory = resolve(tag: .libraryRoot)
        let zipLibraryURL = zipLibraryDirectory.appendingPathComponent(UUID.fixture().uuidString)
        try FileManager.default.createDirectory(at: zipLibraryDirectory, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: zipLibraryURL.path, contents: String.fixture().data(using: .utf8))

        let expectation = self.expectation(description: "Deleted Unused Library")
        _ = try DeletionMonitor(url: zipLibraryURL) { _ in
            XCTAssertFalse(FileManager.default.fileExists(atPath: zipLibraryURL.path))
            expectation.fulfill()
        }
        libraryUpdaterLegacyCleaner.cleanupUnusedLibraries(libraryRepository: libraryRepository)
        wait(for: [expectation], timeout: 4)
        XCTAssert(FileManager.default.fileExists(atPath: libraryRepository.library.url.path))
    }

    func testThatLegacyLibrariesAreDeleted() throws {
        // Old "unzipped" library lives in "Documents" folder ...
        let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let legacyLibraryFolder = documentsFolder.appendingPathComponent(UUID.fixture().uuidString)
        let lcmetajson = legacyLibraryFolder.appendingPathComponent("lcmeta.json")
        try FileManager.default.createDirectory(at: legacyLibraryFolder, withIntermediateDirectories: false)
        FileManager.default.createFile(atPath: lcmetajson.path, contents: String.fixture().data(using: .utf8))

        let nonLibraryFolder = documentsFolder.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: nonLibraryFolder, withIntermediateDirectories: false)

        let expectation = expectation(description: "Legacy library should be delated")
        _ = try DeletionMonitor(url: lcmetajson) { _ in
            XCTAssertFalse(FileManager.default.fileExists(atPath: legacyLibraryFolder.path))
            expectation.fulfill()
        }
        libraryUpdaterLegacyCleaner.cleanupLegacyLibraries(libraryRepository: libraryRepository)
        wait(for: [expectation], timeout: 2)
        XCTAssert(FileManager.default.fileExists(atPath: libraryRepository.library.url.path))
        XCTAssert(FileManager.default.fileExists(atPath: nonLibraryFolder.path))
        try FileManager.default.removeItem(at: nonLibraryFolder)
    }
}

private final class DeletionMonitor: NSObject {

    private let url: URL
    private var callback: ((URL) -> Void)?
    private var timer: Timer?

    init(url: URL, callback: @escaping (URL) -> Void) throws {
        self.url = url
        self.callback = callback
        super.init()
        checkDeletion()
    }

    @objc func checkDeletion() {
        if FileManager.default.fileExists(atPath: url.path) == false {
            callback?(url)
        } else {
            perform(#selector(checkDeletion), with: nil, afterDelay: 0.2, inModes: [.common])
        }
    }

    deinit {
        timer?.invalidate()
    }
}
