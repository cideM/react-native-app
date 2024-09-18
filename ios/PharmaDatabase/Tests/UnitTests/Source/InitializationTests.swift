//
//  PharmaDatabaseTests.swift
//  PharmaDatabaseTests
//
//  Created by Roberto Seidenberg on 31.03.21.
//

import FixtureFactory
import GRDB
@testable import PharmaDatabase
import XCTest

class InitializationTests: XCTestCase {

    func testSuccessInit() throws {
        let queue = try PharmaDatabase.fixture()
        XCTAssertNoThrow(try PharmaDatabase(queue: queue), "PharmaDatabase should init without error")
    }

    func testSuccessInit_WithHigherMinorVersion() throws {
        let major = PharmaDatabase.supportedMajorSchemaVersion
        let minor = PharmaDatabase.supportedMinorSchemaVersion + Int.random(in: 1...100)
        let queue = try PharmaDatabase.fixture(with: [.version(major: major, minor: minor), .ambossSubstance, .section, .drug, .drugSection, .package, .pocketCard, .pocketCardGroup, .pocketCardSection, .dosage])
        XCTAssertNoThrow(try PharmaDatabase(queue: queue), "PharmaDatabase should init without error")
    }

    func testFailureUnsupportedMajorVersion() throws {
        let major = Int.random(in: 0...5)
        let minor = PharmaDatabase.supportedMinorSchemaVersion + Int.random(in: 1...100)
        let patch = Int.random(in: 0...Int.max)
        let queue = try PharmaDatabase.fixture(with: [.version(major: major, minor: minor, patch: patch), .ambossSubstance, .section, .drug, .drugSection, .package])

        XCTAssertThrowsError(try PharmaDatabase(queue: queue), "Should throw error: schema mismatch") { error in
            if case let PharmaDatabase.SchemaValidationError.schemaMajorVersionMismatch(version, requiredVersion) = error {
                XCTAssertEqual(major, version.major)
                XCTAssertEqual(minor, version.minor)
                XCTAssertEqual(patch, version.patch)
                XCTAssertEqual(PharmaDatabase.supportedMajorSchemaVersion, requiredVersion)
            } else {
                XCTFail("Expected error of type .schemaVersionMismatch but got: \(error)")
            }
        }
    }

    func testFailureUnsupportedMinorVersion() throws {

        // Minor version check was introduced along db v5.2

        let major = 10
        let minor = -1 // -> -1 cause minor is currently at "0"
        let patch = Int.random(in: 0...Int.max)
        // This works because the version table is checked before all other tables
        // This db is actually missing a bunch of tables ...
        let queue = try PharmaDatabase.fixture(with: [.version(major: major, minor: minor, patch: patch)])

        XCTAssertThrowsError(try PharmaDatabase(queue: queue), "Should throw error: schema mismatch") { error in
            if case let PharmaDatabase.SchemaValidationError.schemaMinorVersionMismatch(version, requiredVersion) = error {
                XCTAssertEqual(major, version.major)
                XCTAssertEqual(minor, version.minor)
                XCTAssertEqual(patch, version.patch)
                XCTAssertEqual(PharmaDatabase.supportedMinorSchemaVersion, requiredVersion)
            } else {
                XCTFail("Expected error of type .schemaVersionMismatch but got: \(error)")
            }
        }
    }

    func testFailureMissingTable() throws {
        let queue = try PharmaDatabase.fixture(with: []) // <- Database is totally empty at this point
        XCTAssertThrowsError(try PharmaDatabase(queue: queue), "Should throw error: table missing") { error in
            if case let PharmaDatabase.SchemaValidationError.tableMissing(table) = error {
                // The "version" table is the very first thing the adpater checks
                XCTAssertEqual(table, "version")
            } else {
                XCTFail("Expected error of type .tableMissing but got: \(error)")
            }
        }
    }

    func testFailureUnexpectedColumnName() throws {
        struct Version: Codable, PersistableRecord { let id, mayor, minor, patch: Int }
        let queue = try! DatabaseQueue()
        try queue.write { database in
            try database.create(table: "version") { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("mayor", .integer) // -> Misnamed "major" column!
                table.column("minor", .integer)
                table.column("patch", .integer)
            }
            try Version(id: Int.fixture(), mayor: 5, minor: Int.fixture(), patch: Int.fixture()).insert(database)
        }

        XCTAssertThrowsError(try PharmaDatabase(queue: queue), "Should throw error: column missing") { error in
            if case let PharmaDatabase.SchemaValidationError.columnMissing(table, column) = error {
                XCTAssertEqual(table, "version")
                XCTAssertEqual(column, "major")
            } else {
                XCTFail("Expected error of type .columnMissing but got: \(error)")
            }
        }
    }

    func testFailureMissingColumn() throws {
        struct Version: Codable, PersistableRecord { let id, major, minor: Int }
        let queue = try! DatabaseQueue()
        try queue.write { database in
            try database.create(table: "version") { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("major", .integer)
                table.column("minor", .integer)
                // Missing "patch" column!
            }
            try Version(id: Int.fixture(), major: Int.fixture(), minor: Int.fixture()).insert(database)
        }

        XCTAssertThrowsError(try PharmaDatabase(queue: queue), "Should throw error: column missing") { error in
            if case let PharmaDatabase.SchemaValidationError.columnMissing(table, column) = error {
                XCTAssertEqual(table, "version")
                XCTAssertEqual(column, "patch")
            } else {
                XCTFail("Expected error of type .columnMissing but got: \(error)")
            }
        }
    }

    func testThatAnErrorIsThrown_WhenTableIsMissing_AmbossSubstance() throws {
        let queue = try PharmaDatabase.fixture(with: [.version(), .section, .drug, .drugSection, .package])
        checkForMissingTable(queue: queue, table: "amboss_substance")
    }

    func testThatAnErrorIsThrown_WhenTableIsMissing_Section() throws {

        checkForMissingTable(queue: try PharmaDatabase.fixture(with: PharmaDatabase.allTables(except: .section)),
                             table: "section")
    }

    func testThatAnErrorIsThrown_WhenTableIsMissing_Drug() throws {
        checkForMissingTable(queue: try PharmaDatabase.fixture(with: PharmaDatabase.allTables(except: .drug)),
                             table: "drug")
    }

    func testThatAnErrorIsThrown_WhenTableIsMissing_DrugSection() throws {
        checkForMissingTable(queue: try PharmaDatabase.fixture(with: PharmaDatabase.allTables(except: .drugSection)),
                             table: "drug_section")
    }

    func testThatAnErrorIsThrown_WhenTableIsMissing_Package() throws {
        checkForMissingTable(queue: try PharmaDatabase.fixture(with: PharmaDatabase.allTables(except: .package)),
                             table: "package")
    }

    func testThatAnErrorIsThrown_WhenTableIsMissing_PocketCard() throws {
        checkForMissingTable(queue: try PharmaDatabase.fixture(with: PharmaDatabase.allTables(except: .pocketCard)),
                             table: "pocket_card")
    }

    func testThatAnErrorIsThrown_WhenTableIsMissing_PocketCardGroup() throws {
        checkForMissingTable(queue: try PharmaDatabase.fixture(with: PharmaDatabase.allTables(except: .pocketCardGroup)),
                             table: "pocket_card_group")
    }

    func testThatAnErrorIsThrown_WhenTableIsMissing_PocketCardSection() throws {
        checkForMissingTable(queue: try PharmaDatabase.fixture(with: PharmaDatabase.allTables(except: .pocketCardSection)),
                             table: "pocket_card_section")
    }

    func testThatAnErrorIsThrown_WhenTableIsMissing_Dosage() throws {
        checkForMissingTable(queue: try PharmaDatabase.fixture(with: PharmaDatabase.allTables(except: .dosage)),
                             table: "dosage")
    }
}

fileprivate extension InitializationTests {

    func checkForMissingTable(queue: DatabaseQueue, table named: String) {
        XCTAssertThrowsError(try PharmaDatabase(queue: queue), "Should throw error: table missing") { error in
            if case let PharmaDatabase.SchemaValidationError.tableMissing(table) = error {
                XCTAssertEqual(table, named)
            } else {
                XCTFail("Expected error of type .columnMissing but got: \(error)")
            }
        }
    }
}
