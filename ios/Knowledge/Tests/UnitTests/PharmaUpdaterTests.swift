//
//  PharmaUpdaterTests.swift
//  KnowledgeTests
//
//  Created by Silvio Bulla on 07.04.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
@testable import Knowledge_DE
import PharmaDatabase
import XCTest

class PharmaUpdaterTests: XCTestCase {

    var pharmaUpdater: PharmaUpdaterType!
    var pharmaClient: PharmaClientMock!
    var currentVersion: Version!
    var unzipper: UnzipperTypeMock!
    var pharmaDownloader: FileDownloaderTypeMock!

    override func setUpWithError() throws {
        pharmaClient = PharmaClientMock()
        unzipper = UnzipperTypeMock()
        pharmaDownloader = FileDownloaderTypeMock()

        currentVersion = Version(major: 3, minor: 0, patch: 0)
        let workingDirectory = FileManager.default.temporaryDirectory

        pharmaUpdater = try PharmaUpdater(workingDirectory: workingDirectory, unzipper: unzipper, pharmaDownloader: pharmaDownloader, currentVersion: currentVersion, pharmaClient: pharmaClient)
    }

    func testThatIfCurrentPharmaDBIsOutdatedThenCheckForUpdateReturnsTheLastDBUpdate() {
        let pharmaUpdate = PharmaUpdate(version: Version(major: 3, minor: 1, patch: Int.fixture()), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture())

        pharmaClient.getPharmaDatabasesHandler = { _, result in
            result(.success([pharmaUpdate]))
        }

        let exp = expectation(description: "Check for update returns an update. (Out Of Date)")

        pharmaUpdater.checkForUpdate { result in
            switch result {
            case .failure:
                XCTFail("Pharma update isn't returned although the current Pharma database is outdated")
            case .success:
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 0.1)
    }

    func testThatIfCurrentPharmaDBIsUpToDateThenCheckForUpdateDoesNotReturnAnUpdate() {
        let pharmaUpdate = PharmaUpdate(version: currentVersion, size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture())

        pharmaClient.getPharmaDatabasesHandler = { _, result in
            result(.success([pharmaUpdate]))
        }

        let exp = expectation(description: "Check for update does not return an update. (Up To Date)")
        pharmaUpdater.checkForUpdate { result in
            switch result {
            case .failure:
                XCTFail("Pharma check for update failed")
            case .success(let update):
                XCTAssertNil(update)
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 0.1)
    }

    func testThatTheReturnedUpdateHasAMinorVersionThatIsEqualToTheLowestSupportedVersion() {

        // In this case the latest available version also matches the latest minor version the db supports
        let major = PharmaDatabase.supportedMajorSchemaVersion
        let validUpdate = PharmaUpdate(version: Version(major: 10, minor: PharmaDatabase.supportedMinorSchemaVersion, patch: Int.fixture()), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture())
        let updates = [ // Minus values here cause current minor is "0"
            PharmaUpdate(version: Version(major: major, minor: -1, patch: Int.fixture()), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture()),
            PharmaUpdate(version: Version(major: major, minor: -2, patch: Int.fixture()), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture()),
            PharmaUpdate(version: Version(major: major, minor: -3, patch: Int.fixture()), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture()),
            validUpdate
        ]

        pharmaClient.getPharmaDatabasesHandler = { _, result in
            result(.success(updates.shuffled()))
        }

        let count = updates.count * 3 // Just shuffle often enought so likely all cases are covered
        let exp = expectation(description: "Check for update does return the expected version for the update.")
        exp.expectedFulfillmentCount = count

        for _ in 0..<count {
            pharmaUpdater.checkForUpdate { result in
                switch result {
                case .failure:
                    XCTFail("Pharma check for update failed")
                case .success(let update):
                    guard let update = update else { return XCTFail("Update should not be nil") }
                    XCTAssertEqual(update, validUpdate)
                    print(update.version)
                    exp.fulfill()
                }
            }
        }

        wait(for: [exp], timeout: 1)
    }

    func testThatTheReturnedUpdateHasAMinorVersionThatIsHigherThanTheLowestSupportedVersion() {

        // In this case the latest available version is above the latest minor version the db supports
        let major = PharmaDatabase.supportedMajorSchemaVersion
        let validUpdate = PharmaUpdate(version: Version(major: major, minor: PharmaDatabase.supportedMinorSchemaVersion + 2, patch: 0), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture())
        let updates = [ // Minus values here cause current minor is "0"
            PharmaUpdate(version: Version(major: major, minor: -1, patch: Int.fixture()), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture()),
            PharmaUpdate(version: Version(major: major, minor: -2, patch: Int.fixture()), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture()),
            PharmaUpdate(version: Version(major: major, minor: -3, patch: Int.fixture()), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture()),
            PharmaUpdate(version: Version(major: major, minor: -4, patch: Int.fixture()), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture()),
            PharmaUpdate(version: Version(major: major, minor: -5, patch: Int.fixture()), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture()),
            validUpdate
        ]

        pharmaClient.getPharmaDatabasesHandler = { _, result in
            result(.success(updates.shuffled()))
        }

        let count = updates.count * 3 // Just shuffle often enought so likely all cases are covered
        let exp = expectation(description: "Check for update does return the expected version for the update.")
        exp.expectedFulfillmentCount = count

        for _ in 0..<count {
            pharmaUpdater.checkForUpdate { result in
                switch result {
                case .failure:
                    XCTFail("Pharma check for update failed")
                case .success(let update):
                    guard let update = update else { return XCTFail("Update should not be nil") }
                    XCTAssertEqual(update, validUpdate)
                    print(update.version)
                    exp.fulfill()
                }
            }
        }

        wait(for: [exp], timeout: 1)
    }

    func testThatNoUpdateIsReturnedIfNoneWasReturnedByTheServerThatIsSupportedByTheDBAdapter() {

        // In this case the latest available version is below the latest minor version the db supports
        let major = PharmaDatabase.supportedMajorSchemaVersion
        let updates = [ // Minus values here cause current minor is "0"
            PharmaUpdate(version: Version(major: major, minor: -1, patch: Int.fixture()), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture()),
            PharmaUpdate(version: Version(major: major, minor: -2, patch: Int.fixture()), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture()),
            PharmaUpdate(version: Version(major: major, minor: -3, patch: Int.fixture()), size: .fixture(), zippedSize: .fixture(), url: .fixture(), date: .fixture())
        ]

        pharmaClient.getPharmaDatabasesHandler = { _, result in
            result(.success(updates.shuffled()))
        }

        let count = updates.count * 3 // Just shuffle often enought so likely all cases are covered
        let exp = expectation(description: "Check for update does return the expected version for the update.")
        exp.expectedFulfillmentCount = count

        for _ in 0..<count {
            pharmaUpdater.checkForUpdate { result in
                switch result {
                case .failure:
                    XCTFail("Pharma check for update failed")
                case .success(let update):
                    XCTAssertNil(update)
                    exp.fulfill()
                }
            }
        }

        wait(for: [exp], timeout: 1)
    }

    func testThatPharmaUpdateVersionIsComparable() {
        let versionOne = Version(major: 1, minor: 0, patch: 4)
        let versionTwo = Version(major: 1, minor: 1, patch: 6)
        let versionThree = Version(major: 1, minor: 1, patch: 6)
        let versionFour = Version(major: 2, minor: 0, patch: 3)

        XCTAssertTrue(versionOne < versionTwo)
        XCTAssertTrue(versionOne < versionThree)
        XCTAssertTrue(versionTwo > versionOne)
        XCTAssertTrue(versionTwo == versionThree)
        XCTAssertTrue(versionFour > versionThree)
    }
}
