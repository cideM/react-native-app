//
//  ExtensionMetadataTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 17.11.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

@testable import Knowledge_DE
import XCTest

class ExtensionMetadataTests: XCTestCase {

    func testExtensionMetadataIsInitialisedWithoutIsEmptyNoteProperty() {
        let data = "{\"learningCard\":\"fixture_GLaX4WYJB8\",\"section\":\"fixture_dZC14Rb\",\"updatedAt\":626665686.06796396,\"previousUpdatedAt\":626849286.06822896}".data(using: .utf8)!

        let decodedExtensionMetadata = try? JSONDecoder().decode(ExtensionMetadata.self, from: data)

        XCTAssertNotNil(decodedExtensionMetadata)
        XCTAssertFalse(decodedExtensionMetadata!.isEmptyNote)
    }

    func testExtensionMetadataIsInitialisedWithIsEmptyNotePropertySetToTrue() {
        let extensionMetadata = ExtensionMetadata.fixture(ext: .fixture(note: ""))
        let data = try! JSONEncoder().encode(extensionMetadata)

        let decodedExtensionMetadata = try! JSONDecoder().decode(ExtensionMetadata.self, from: data)

        XCTAssertTrue(decodedExtensionMetadata.isEmptyNote)
    }
}
