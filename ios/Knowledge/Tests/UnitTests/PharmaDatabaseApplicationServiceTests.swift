//
//  PharmaDatabaseApplicationServiceTests.swift
//  KnowledgeTests
//
//  Created by Roberto Seidenberg on 07.04.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import GRDB
import Domain
@testable import Knowledge_DE
@testable import PharmaDatabase
import XCTest

class PharmaDatabaseApplicationServiceTests: XCTestCase {

    // Just putting this into a var to make stuff below more readable ...
    let pharma = PharmaOfflineDatabaseApplicationServiceDidChangeStateNotification.self

    // MARK: - Init

    func testThat_automaticUpdate_isNotTriggered_onInit() throws {
        let container = try makeDependencies()
        switch container.service.state {
        case .idle(let error, let availableUpdate, let updateType):
            XCTAssertNil(error)
            XCTAssertNil(availableUpdate)
            XCTAssertEqual(updateType, PharmaDatabaseUpdateType.automatic)
        default:
            XCTFail("Initial state should be: idle, but is instead: \(container.service.state)")
        }

        XCTAssertEqual(container.updater.checkForUpdateCallCount, 0)
        XCTAssertEqual(container.updater.updateCallCount, 0)
    }

    // MARK: - Version validation

    func testThat_existingIncompatibleDBVersion_isDeleted_onInit() throws {
        let container = try makeDependencies()
        let applicationServiceDBDirectory = container.applicationServiceDBFile.deletingLastPathComponent().deletingLastPathComponent()

        let outdatedVersions = [PharmaDatabase.supportedMajorSchemaVersion - 1,
                                PharmaDatabase.supportedMajorSchemaVersion - 2,
                                PharmaDatabase.supportedMajorSchemaVersion - 3]
        for major in outdatedVersions {
            let directory = applicationServiceDBDirectory.appendingPathComponent("\(major)")
            let file = directory.appendingPathComponent(PharmaDatabaseApplicationService.databaseFilename())
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try makeDatabase(at: file, version: Version.fixture(major: major, minor: 0, patch: 0))
            XCTAssertTrue(FileManager.default.fileExists(atPath: directory.path))
        }

        // Versions below "PharmaDatabase.supportedMajorSchemaVersion" should be delete during init ...
        _ = try PharmaDatabaseApplicationService(updater: container.updater, trackingProvider: TrackingTypeMock(), workingDirectory: container.workingDirectory, storage: MemoryStorage(), featureFlagRepository: FeatureFlagRepositoryTypeMock())

        for major in outdatedVersions {
            let directory = applicationServiceDBDirectory.appendingPathComponent("\(major)")
            XCTAssertFalse(FileManager.default.fileExists(atPath: directory.path))
        }
    }

    func testThat_existingIncompatibleMinorDBVersion_isDeleted_onInit() throws {
        let container = try makeDependencies()
        let applicationServiceDBDirectory = container.applicationServiceDBFile.deletingLastPathComponent().deletingLastPathComponent()

        let major = PharmaDatabase.supportedMajorSchemaVersion
        let outdatedMinorVersion = PharmaDatabase.supportedMinorSchemaVersion - 1
        let directory = applicationServiceDBDirectory.appendingPathComponent("\(major)")
        let file = directory.appendingPathComponent(PharmaDatabaseApplicationService.databaseFilename())
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try makeDatabase(at: file, version: Version.fixture(major: major, minor: outdatedMinorVersion, patch: Int.fixture()))
        XCTAssertTrue(FileManager.default.fileExists(atPath: directory.path))

        // Minor version is not supported hence should be deleted ...
        _ = try PharmaDatabaseApplicationService(updater: container.updater, trackingProvider: TrackingTypeMock(), workingDirectory: container.workingDirectory, storage: MemoryStorage(), featureFlagRepository: FeatureFlagRepositoryTypeMock())
        XCTAssertFalse(FileManager.default.fileExists(atPath: directory.path))
    }

    // MARK: - Automatic updates

//    func testThat_automaticUpdate_isOnlyTriggered_onAppLaunch_ifThereIsAPreexistingDatabase() throws {
//        let container = try makeDependencies()
//        let checkForUpdateExpectation = expectation(description: "Check for update should be called")
//        let updateExpectation = expectation(description: "Update should be called")
//        let callCountExpectation = expectation(description: "State should update expected times")
//
//        container.service.isBackgroundUpdatesEnabled = true
//
//        container.updater.checkForUpdateHandler = { completion in
//            switch container.service.state {
//            case .checking:
//                break
//            default:
//                XCTFail("State should be: checking, but is instead: \(container.service.state)")
//            }
//            completion(.success(PharmaUpdate.fixture(version: container.version)))
//            checkForUpdateExpectation.fulfill()
//        }
//
//        container.updater.updateHandler = { _, progress, completion in
//            let randomProgress = Double.random(in: 0...1)
//            progress(randomProgress)
//            switch container.service.state {
//            case .downloading(let update, let progress):
//                XCTAssertEqual(update.version, container.version)
//                XCTAssertEqual(progress, randomProgress)
//            default:
//                XCTFail("State should be: downloading, but is instead: \(container.service.state)")
//            }
//            completion(.success(container.updaterDBFile))
//            updateExpectation.fulfill()
//        }
//
//        var callCount = 0
//
//        let observation = NotificationCenter.default.observe(for: pharma, object: container.service, queue: .main) { notification in
//            callCount += 1
//            guard callCount == 4  else { return }
//
//            // Only run this at the very last state update
//            switch notification.newValue {
//            case .idle(let error, let availableUpdate, let updateType):
//                XCTAssertNil(error)
//                XCTAssertNil(availableUpdate)
//                XCTAssertEqual(updateType, .automatic)
//                XCTAssertTrue(FileManager.default.fileExists(atPath: container.applicationServiceDBFile.path))
//                XCTAssertNotNil(container.service.pharmaDatabase)
//            default:
//                XCTFail("State should be: idle and contain no error, but is instead: \(container.service.state)")
//            }
//
//            callCountExpectation.fulfill()
//        }
//        _ = try makeDatabase(at: container.applicationServiceDBFile, version: Version.fixture(major: PharmaDatabase.supportedMajorSchemaVersion, minor: PharmaDatabase.supportedMinorSchemaVersion))
//        _ = container.service.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
//        wait(for: [checkForUpdateExpectation, updateExpectation, callCountExpectation], timeout: 5)
//        observation.cancel()
//    }

    func testThat_automaticUpdate_isNotTriggered_onAppLaunch_ifThereIsNoPreexistingDatabase() throws {
         let container = try makeDependencies()
         let graceTimeExpectation = expectation(description: "Check for update should be called")
         let noDBToUpdateExpectation = expectation(description: "noDatabaseToUpdate error is received")

        container.updater.checkForUpdateHandler = { completion in
            completion(.success(.fixture()))
        }

         let observation = NotificationCenter.default.observe(for: pharma, object: container.service, queue: .main) { notification in
            switch notification.newValue {
            case .idle(let error, _, _):
                switch error {
                case .noDatabaseToUpdate:
                    noDBToUpdateExpectation.fulfill()
                default:
                    XCTFail()
                }
            case .checking: break
            default:
                XCTFail()
            }
         }

         DispatchQueue.main.asyncAfter(deadline: .now() + 2.seconds) {
             graceTimeExpectation.fulfill()
         }

         // This should never trigger a state change since this function does nothing
         // if no database exists yet
         _ = container.service.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
         wait(for: [graceTimeExpectation, noDBToUpdateExpectation], timeout: 3)
         observation.cancel()
     }

    // MARK: - Error cases: Check for update

    func testThat_aCheckForUpdate_returningAnError_resultsIn_anIdleStateWithAnError() throws {
        let container = try makeDependencies()
        let checkForUpdateExpectation = expectation(description: "Check for update should be called")
        let callCountExpectation = expectation(description: "State should update expected times")

        container.updater.checkForUpdateHandler = { completion in
            completion(.failure(PharmaUpdaterError.underlyingError(error: nil)))
            checkForUpdateExpectation.fulfill()
        }

        var callCount = 0
        let observation = NotificationCenter.default.observe(for: pharma, object: container.service, queue: .main) { notification in
            callCount += 1
            guard callCount == 2  else { return }

            switch notification.newValue {
            case .idle(let error, let availableUpdate, let updateType):
                guard let error = error else { return XCTFail("Error must not be nil") }
                switch error {
                case .downloadFailed(PharmaUpdaterError.underlyingError): break
                default: XCTFail("Error is of unexpected type")
                }
                XCTAssertNil(availableUpdate)
                XCTAssertEqual(updateType, .manual)
            default:
                XCTFail("State should be: idle and contain an error, but is instead: \(container.service.state)")
            }

            callCountExpectation.fulfill()
        }

        try container.service.checkForUpdate()
        wait(for: [checkForUpdateExpectation, callCountExpectation], timeout: 10)
        observation.cancel()
    }

    func testThat_callingCheckForUpdate_whileAnUpdateisRunning_resultsIn_aThrownError() throws {
        let container = try makeDependencies()
        container.updater.checkForUpdateHandler = { _ in
            // Make this stuck on purpose, so the second call to "checkForUpdate" will throw an error
            // Because: the service is still busy with this check
        }

        try container.service.checkForUpdate() // <- should work fine cause not busy
        XCTAssertThrowsError(try container.service.checkForUpdate(), "Should throw \"busy\" error") { error in
            switch error {
            case PharmaDatabaseApplicationServiceError.busy: break
            default: XCTFail("Error is of unexpected type")
            }
        }
    }

    // MARK: - Error cases: Update

    func testThat_anInvalidFileURL_resultsIn_anIdleStateWithAnErrorAndAnAvailableUpdate() throws {
        let container = try makeDependencies()
        let checkForUpdateExpectation = expectation(description: "Check for update should be called")
        let updateExpectation = expectation(description: "Update should be called")
        let callCountExpectation = expectation(description: "State should update expected times")

        // Remove the file that the updater is supposed to deliver ...
        XCTAssertNoThrow(try FileManager.default.removeItem(at: container.updaterDBFile))

        container.updater.checkForUpdateHandler = { completion in
            completion(.success(PharmaUpdate.fixture(version: container.version)))
            checkForUpdateExpectation.fulfill()
        }

        container.updater.updateHandler = { _, _, completion in
            completion(.success(container.updaterDBFile))
            updateExpectation.fulfill()
        }

        var callCount = 0
        let observation = NotificationCenter.default.observe(for: pharma, object: container.service, queue: .main) { notification in
            callCount += 1
            guard callCount == 2  else { return }

            switch notification.newValue {
            case .idle(let error, let update, let updateType):
                switch error {
                case .downloadFailed: break
                default: XCTFail()
                }
                XCTAssertEqual(update?.version, container.version)
                XCTAssertEqual(updateType, .manual)
            default:
                XCTFail("State should be: idle and contain an error, but is instead: \(container.service.state)")
            }

            callCountExpectation.fulfill()
        }

        try container.service.startManualUpdate()
        wait(for: [checkForUpdateExpectation, updateExpectation, callCountExpectation], timeout: 5)
        observation.cancel()
    }

    func testThat_anUpdateErrorViaUpdater_resultsIn_anIdleStateWithAnErrorAndAnAvailableUpdate() throws {
        let container = try makeDependencies()
        let updateExpectation = expectation(description: "Update should be called")
        let callCountExpectation = expectation(description: "State should update expected times")

        let update = PharmaUpdate.fixture()
        container.updater.checkForUpdateHandler = { completion in
            completion(.success(update))
        }

        container.updater.updateHandler = { _, _, completion in
            completion(.failure(PharmaUpdaterError.underlyingError(error: nil)))
            updateExpectation.fulfill()
        }

        var callCount = 0
        let observation = NotificationCenter.default.observe(for: pharma, object: container.service, queue: .main) { notification in
            callCount += 1
            guard callCount == 2  else { return }

            switch notification.newValue {
            case .idle(let error, let availableUpdate, let updateType):
                guard let error = error else { return XCTFail("Error must not be nil") }
                switch error {
                case .downloadFailed(PharmaUpdaterError.underlyingError): break
                default: XCTFail("Error is of unexpected type")
                }
                XCTAssertEqual(update, availableUpdate)
                XCTAssertEqual(updateType, .manual)
            default:
                XCTFail("State should be: idle and contain an error and and an update, but is instead: \(container.service.state)")
            }

            callCountExpectation.fulfill()
        }

        try container.service.startManualUpdate()
        wait(for: [updateExpectation, callCountExpectation], timeout: 5)
        observation.cancel()
    }

//    func testThat_anUpdateContainingAnIncompatibleDBVersion_resultsIn_anIdleStateWithAnErrorAndAnAvailableUpdate() throws {
//        // This test covers the case when the file delivered via backend is a different (incompatible) version
//        // than advertised in the json returned from the update check
//
//        let container = try makeDependencies()
//        let updateExpectation = expectation(description: "Update should be called")
//        let callCountExpectation = expectation(description: "State should update expected times")
//
//        // Overwrite the valid "makeDependencies()" db with an outdated one ...
//        let outdated = Domain.Version(major: 2, minor: Int.fixture(), patch: Int.fixture())
//        try makeDatabase(at: container.updaterDBFile, version: outdated)
//
//        let update = PharmaUpdate.fixture()
//        container.updater.checkForUpdateHandler = { completion in
//            completion(.success(update))
//        }
//
//        container.updater.updateHandler = { _, _, completion in
//            completion(.success(container.updaterDBFile))
//            updateExpectation.fulfill()
//        }
//
//        var callCount = 0
//        let observation = NotificationCenter.default.observe(for: pharma, object: container.service, queue: .main) { notification in
//            callCount += 1
//            guard callCount == 3  else { return }
//
//            switch notification.newValue {
//            case .idle(let error, let availableUpdate, let updateType):
//                guard let error = error else { return XCTFail("Error must not be nil") }
//                switch error {
//                case .downloadFailed(PharmaUpdaterError.underlyingError(let error)):
//                    guard let error = error as? PharmaDatabase.SchemaValidationError else {
//                        XCTFail()
//                        return
//                    }
//                    switch error {
//                    case .schemaMajorVersionMismatch(let version, let required):
//                        XCTAssertEqual(outdated.major, version.major)
//                        XCTAssertEqual(outdated.minor, version.minor)
//                        XCTAssertEqual(outdated.patch, version.patch)
//                        XCTAssertEqual(update, availableUpdate)
//                        XCTAssertEqual(updateType, .manual)
//                        XCTAssertEqual(PharmaDatabase.supportedMajorSchemaVersion, required)
//                    default:
//                        XCTFail()
//                    }
//                default:
//                    XCTFail("Error is of unexpected type")
//                }
//            default:
//                XCTFail("State should be: idle and contain an error and and an update, but is instead: \(container.service.state)")
//            }
//
//            callCountExpectation.fulfill()
//        }
//
//        try container.service.startManualUpdate()
//        wait(for: [updateExpectation, callCountExpectation], timeout: 5)
//        observation.cancel()
//    }
//
//    func testThat_replacingACurrentlyOpenDB_resultsIn_noErrorAndTheNewDBBeingAvailable() throws {
//        let initialVersion = Domain.Version(major: PharmaDatabase.supportedMajorSchemaVersion, minor: PharmaDatabase.supportedMinorSchemaVersion, patch: Int.fixture())
//        let container = try makeDependencies(database: initialVersion)
//
//        let initialDBInstallExpectation = expectation(description: "Initial db should be installed")
//        let updatedDBInstallExpectation = expectation(description: "Updated db should be installed")
//
//        container.updater.checkForUpdateHandler = { completion in
//            completion(.success(PharmaUpdate.fixture(version: container.version)))
//        }
//
//        container.updater.updateHandler = { _, _, completion in
//            completion(.success(container.updaterDBFile))
//        }
//
//        // Iterating through some of the possible states during the update cycle ...
//        var updatedVersion: Domain.Version!
//        let observation = NotificationCenter.default.observe(for: pharma, object: container.service, queue: .main) { notification in
//            switch notification.newValue {
//            case .idle:
//                do {
//                    let version = try container.service.pharmaDatabase?.version()
//                    if version == initialVersion {
//                        initialDBInstallExpectation.fulfill()
//                    } else if version == updatedVersion {
//                        updatedDBInstallExpectation.fulfill()
//                    } else {
//                        XCTFail("Unexpected db version")
//                    }
//                } catch {
//                    XCTFail(error.localizedDescription)
//                }
//            default:
//                break
//            }
//        }
//
//        try container.service.startManualUpdate()
//        wait(for: [initialDBInstallExpectation], timeout: 15)
//        guard let initialPharmaDatabase = container.service.pharmaDatabase else {
//            return XCTFail("Pharma database should not be nil")
//        }
//
//        updatedVersion = try makeDatabase(at: container.updaterDBFile, version: Version.fixture(major: PharmaDatabase.supportedMajorSchemaVersion, minor: PharmaDatabase.supportedMinorSchemaVersion, patch: Int.fixture()))
//        try container.service.startManualUpdate()
//        wait(for: [updatedDBInstallExpectation], timeout: 15)
//
//        // Make sure the old db handle is now invalid ...
//        XCTAssertThrowsError(try initialPharmaDatabase.version(), "Overwritten sqlite db should throw an io error") { error in
//            guard let grdbError = error as? GRDB.DatabaseError else { return XCTFail("Error is of unexpected type: \(error)") }
//            XCTAssertEqual(grdbError.resultCode.rawValue, 10)
//            XCTAssertEqual(grdbError.message, "disk I/O error")
//        }
//
//        observation.cancel()
//    }

    func testThat_whenDeleteDatabaseIsCalled_theCurrentDatabaseIsDeleted() throws {
        let container = try makeDependencies()

        let applicationServiceDBDirectory = container.applicationServiceDBFile.deletingLastPathComponent().deletingLastPathComponent()
        let major = PharmaDatabase.supportedMajorSchemaVersion
        let directory = applicationServiceDBDirectory.appendingPathComponent("\(major)")
        let file = directory.appendingPathComponent(PharmaDatabaseApplicationService.databaseFilename())
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try makeDatabase(at: file, version: Version.fixture(major: major, minor: 1, patch: 0))
        XCTAssertTrue(FileManager.default.fileExists(atPath: directory.path))

        container.updater.checkForUpdateHandler = { completion in
            completion(.success(.fixture()))
        }

        let deleteExpectation = expectation(description: "Delete database should be called")
        do {
            try container.service.deleteDatabase()
            deleteExpectation.fulfill()
        } catch {
            XCTFail("Delete database isn't getting called")
        }

        XCTAssertEqual(container.updater.currentVersion, Version.fixture(major: major, minor: 0, patch: 0))
        XCTAssertNil(FileManager.default.contents(atPath: directory.path))
        wait(for: [deleteExpectation], timeout: 0.1)
    }

    func testThat_whenDeleteDatabaseIsCalled_theCurrentDatabaseIsDeleted_and_theCurrentUpdateIsCanceled() throws {
        let container = try makeDependencies()

        let applicationServiceDBDirectory = container.applicationServiceDBFile.deletingLastPathComponent().deletingLastPathComponent()
        let major = PharmaDatabase.supportedMajorSchemaVersion
        let directory = applicationServiceDBDirectory.appendingPathComponent("\(major)")
        let file = directory.appendingPathComponent(PharmaDatabaseApplicationService.databaseFilename())
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try makeDatabase(at: file, version: Version.fixture(major: major, minor: 1, patch: 0))
        XCTAssertTrue(FileManager.default.fileExists(atPath: directory.path))

        container.updater.checkForUpdateHandler = { completion in
            completion(.success(.fixture()))
        }

        let cancelExpectation = expectation(description: "Cancel runnning task on updater should be called")
        container.updater.cancelHandler = {
            cancelExpectation.fulfill()
        }

        try container.service.deleteDatabase()

        XCTAssertEqual(container.updater.currentVersion, Version.fixture(major: major, minor: 0, patch: 0))
        XCTAssertNil(FileManager.default.contents(atPath: directory.path))
        wait(for: [cancelExpectation], timeout: 0.1)
    }
}

// MARK: - Helpers

private extension PharmaDatabaseApplicationServiceTests {

    class TestDependencyContainer: NSObject {
        let service: PharmaDatabaseApplicationService
        let updater: PharmaUpdaterTypeMock
        let version: Domain.Version
        let workingDirectory: URL
        let updaterDBFile: URL
        let applicationServiceDBFile: URL

        init(service: PharmaDatabaseApplicationService, updater: PharmaUpdaterTypeMock, version: Domain.Version, workingDirectory: URL, updaterDBFile: URL, applicationServiceDBFile: URL) {
            self.service = service
            self.updater = updater
            self.version = version
            self.workingDirectory = workingDirectory
            self.updaterDBFile = updaterDBFile
            self.applicationServiceDBFile = applicationServiceDBFile
            super.init()
        }
    }

    func makeDependencies(database version: Domain.Version? = nil) throws -> TestDependencyContainer {
        let version = version ?? Domain.Version.fixture(major: PharmaDatabase.supportedMajorSchemaVersion, minor: PharmaDatabase.supportedMinorSchemaVersion)
        let updater = PharmaUpdaterTypeMock(currentVersion: version)
        let tracker = TrackingTypeMock()

        // Prepare application service working directory ...
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let workingDirectory = docs.appendingPathComponent("pharmaApplicationServiceTestsWorkingDirectory_" + String.fixture())
        try FileManager.default.createDirectory(at: workingDirectory, withIntermediateDirectories: true)
        let applicationServiceDBFile = PharmaDatabaseApplicationService.pharmaDatabaseFileURL(in: workingDirectory)

        // Prepare database in updater directory ...
        let updaterDirectory = try PharmaUpdater.workingDirectory(in: workingDirectory)
        try FileManager.default.createDirectory(at: updaterDirectory, withIntermediateDirectories: true)
        let updaterDBFile = updaterDirectory.appendingPathComponent(PharmaUpdater.dbFilenameInArchive)
        let dbVersion = try makeDatabase(at: updaterDBFile, version: version)

        // Make application service which uses above values ...
        let service = try PharmaDatabaseApplicationService(updater: updater, trackingProvider: tracker, workingDirectory: workingDirectory, storage: MemoryStorage(), featureFlagRepository: FeatureFlagRepositoryTypeMock())

        return TestDependencyContainer(service: service, updater: updater, version: dbVersion, workingDirectory: workingDirectory, updaterDBFile: updaterDBFile, applicationServiceDBFile: applicationServiceDBFile)
    }

    @discardableResult func makeDatabase(at url: URL, version: Domain.Version) throws -> Domain.Version {
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }

        let queue = try DatabaseQueue(path: url.path)
        try queue.write { database in

            // All tables for the supported schema version must exist
            // Otherwise db validation will fail on wrapper init

            try database.create(table: "version") { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("major", .integer)
                table.column("minor", .integer)
                table.column("patch", .integer)
            }

            try database.create(table: "amboss_substance") { table in
                table.column("id", .text)
                table.column("name", .text)
                table.column("based_on_drug_id", .text)
                table.column("prescriptions", .text)
                table.column("dosage_forms", .text)
                table.column("published_at_ts", .integer)
                table.column("search_terms", .text)
                table.column("suggest_terms", .text)
                table.column("embryotox", .text)
                table.column("published", .boolean)
            }

            try database.create(table: "section") { table in
                table.column("id", .integer)
                table.column("title", .text)
                table.column("content", .blob)
            }

            try database.create(table: "drug") { table in
                table.column("id", .text)
                table.column("name", .text)
                table.column("atc_label", .text)
                table.column("amboss_substance_id", .text)
                table.column("vendor", .text)
                table.column("application_forms", .text)
                table.column("prescriptions", .text)
                table.column("dosage_forms", .text)
                table.column("published_at_ts", .integer)
                table.column("prescribing_information_url", .text)
                table.column("patient_package_insert_url", .text)
            }

            try database.create(table: "drug_section") { table in
                table.column("drug_id", .text)
                table.column("section_id", .text)
                table.column("position", .integer)
            }

            try database.create(table: "package") { table in
                table.column("id", .integer)
                table.column("drug_id", .text)
                table.column("position_mixed", .integer)
                table.column("position_ascending", .integer)
                table.column("package_size", .text)
                table.column("amount", .text)
                table.column("unit", .text)
                table.column("pharmacy_price", .text)
                table.column("recommended_price", .text)
                table.column("prescription", .text)
            }

            try database.create(table: "dosage") { table in
                table.column("id", .integer)
                table.column("html", .text)
                table.column("as_link_as_id", .text)
                table.column("as_link_drug_id", .text)
            }

            let versionRow = PharmaDatabase.Row.Version(id: Int.fixture(), major: version.major, minor: version.minor, patch: version.patch)
            try versionRow.insert(database)
        }

        return version
    }
}

extension PharmaDatabase.Row.Version: PersistableRecord {}
