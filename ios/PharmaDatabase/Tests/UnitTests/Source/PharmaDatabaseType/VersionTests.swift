//
//  PharmaDatabaseAPIVersionTest.swift
//  PharmaDatabaseTests
//
//  Created by Roberto Seidenberg on 01.04.21.
//

import FixtureFactory
import GRDB
@testable import PharmaDatabase
import XCTest

class VersionTests: XCTestCase {

    func testSuccessVersion() throws {

        let major = PharmaDatabase.supportedMajorSchemaVersion
        let minor = PharmaDatabase.supportedMinorSchemaVersion
        let patch = Int.random(in: 0...Int.max)

        let queue = try PharmaDatabase.fixture(with: [.version(major: major, minor: minor, patch: patch), .ambossSubstance, .section, .drug, .drugSection, .package, .pocketCard, .pocketCardGroup, .pocketCardSection, .dosage]) // <- defaults to valid version
        let database = try PharmaDatabase(queue: queue)
        let version = try XCTUnwrap(database.version())

        XCTAssertEqual(major, version.major)
        XCTAssertEqual(minor, version.minor)
        XCTAssertEqual(patch, version.patch)
    }

    func testFailureMissingVersionRow() throws {
        let queue = try PharmaDatabase.fixture(with: [.version(insert: false)])
        XCTAssertThrowsError(try PharmaDatabase(queue: queue), "Should throw error: row missing") { error in
            let description = String(describing: error)
            let expected = "rowMissing(table: \"version\")"
            XCTAssertEqual(description, expected)
        }
    }

    func testFailureMissingVersionRowAfterSuccesfullInit() throws {
        // Database has a version row ...
        let queue = try PharmaDatabase.fixture()
        let database = try PharmaDatabase(queue: queue)

        // ... removing version row ...
        try queue.write { database in
            let version = try PharmaDatabase.Row.Version.fetchOne(database)
            try version?.delete(database)
        }

        // Accessing version row is now impossible ...
        XCTAssertThrowsError(try database.version(), "Should throw error: row missing") { error in
            let description = String(describing: error)
            let expected = "rowMissing(table: \"version\")"
            XCTAssertEqual(description, expected)
        }
    }
}
