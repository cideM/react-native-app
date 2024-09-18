//
//  FileStorageTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 18.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
@testable import Knowledge_DE
import XCTest

class FileStorageTests: XCTestCase {

    private var fileStorage: FileStorage!

    override func setUp() {
        fileStorage = FileStorage(with: FileManager.default.temporaryDirectory.appendingPathComponent("FileStorage"))
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: FileManager.default.temporaryDirectory.appendingPathComponent("FileStorage"))
    }

    func testThatStoringFilesInTheFileStorageSucceed() {
        let data: String = "FileStorage data"
        fileStorage.store(data, for: "savedFile")

        XCTAssertTrue(FileManager().fileExists(atPath: FileManager.default.temporaryDirectory.appendingPathComponent("FileStorage").appendingPathComponent("savedFile").path))
    }

    func testThatASetStringCanBeGetAgain() {
        let data: String = "FileStorage data"
        fileStorage.store(data, for: "savedFile")
        let fetched: String? = fileStorage.get(for: "savedFile")
        XCTAssertEqual(fetched, "FileStorage data")
    }

    func testThatGettingAFileFromTheFileStorageSucceed() {
        let data = LibraryUpdate(version: 100, url: URL(string: "www.spec.com")!, updateMode: LibraryUpdateMode.can, size: 64, createdAt: Date())
        fileStorage.store(data, for: "savedFile")

        let fileRetrievedData: LibraryUpdate? = fileStorage.get(for: "savedFile")
        XCTAssertNotNil(fileRetrievedData)
    }

    func testThatGettingDataForANonExistingFileFromTheFileStorageFails() {
        let fileRetrievedData: Data? = fileStorage.get(for: "InvalidFileUrl")
        XCTAssertNil(fileRetrievedData)
    }

    func testThatOverwritingAFileWorksAsExpected() {
        let data = LibraryUpdate(version: 100, url: URL(string: "www.spec.com")!, updateMode: LibraryUpdateMode.can, size: 64, createdAt: Date())
        fileStorage.store(data, for: "savedFile")

        let newData = LibraryUpdate(version: 120, url: URL(string: "www.spec_1.com")!, updateMode: LibraryUpdateMode.should, size: 68, createdAt: Date())
        fileStorage.store(newData, for: "savedFile")

        let fileRetrievedData: LibraryUpdate? = fileStorage.get(for: "savedFile")
        XCTAssertEqual(fileRetrievedData?.version, newData.version)
        XCTAssertEqual(fileRetrievedData?.url, newData.url)
        XCTAssertEqual(fileRetrievedData?.updateMode, newData.updateMode)
        XCTAssertEqual(fileRetrievedData?.size, newData.size)
        XCTAssertEqual(fileRetrievedData?.createdAt, newData.createdAt)
    }

    func testThatSettingAValueForAKeyToNilRemovesTheValue() {
        let value: String = .fixture()
        let key = "key"
        fileStorage.store(value, for: key)

        fileStorage.store(nil as String?, for: key)

        let storedValue: String? = fileStorage.get(for: key)
        XCTAssertNil(storedValue)
    }
}
