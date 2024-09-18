//
//  PharmaDatabaseApplicationService.swift
//  Knowledge
//
//  Created by Roberto Seidenberg on 01.04.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common
import Domain
import PharmaDatabase
import UIKit

final class PharmaDatabaseApplicationService: PharmaDatabaseApplicationServiceType {

    private(set) var state: PharmaDatabaseApplicationServiceState = .idle(error: nil, availableUpdate: nil, type: .automatic) {
        didSet {
            let notification = PharmaOfflineDatabaseApplicationServiceDidChangeStateNotification(oldValue: oldValue, newValue: state)
            NotificationCenter.default.post(notification, sender: self)
        }
    }
    private(set) var pharmaDatabase: PharmaDatabaseType?

    private var updater: PharmaUpdaterType
    private let trackingProvider: TrackingType
    private let storage: Storage
    let featureFlagRepository: FeatureFlagRepositoryType

    private let workingDirectory: URL
    private let temporaryFile: URL
    private let databaseFile: URL
    private let monitor: Monitoring = resolve()

    private let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .background
        return queue
    }()

    init(updater: PharmaUpdaterType, trackingProvider: TrackingType = resolve(), workingDirectory: URL, storage: Storage, featureFlagRepository: FeatureFlagRepositoryType = resolve()) throws {

        self.trackingProvider = trackingProvider
        self.storage = storage
        self.workingDirectory = workingDirectory
        self.updater = updater
        self.featureFlagRepository = featureFlagRepository

        temporaryFile = Self.temporaryFilename(in: workingDirectory) // -> DB is stored here for a brief moment to prevent the updater from deleting it
        databaseFile = Self.pharmaDatabaseFileURL(in: workingDirectory) // -> Final destination of a valid DB

        do {
            // Setup and clean directory structure ...
            try Self.removeOutdatedDatabaseVersions(in: workingDirectory) // -> Do not open an incompatible version after a major schema update
            try Self.createDirectories(in: workingDirectory)
            try Self.removeTemporaryFiles(in: workingDirectory)

            // Check which db we already have and let the updater know ...
            if FileManager.default.fileExists(atPath: databaseFile.path) {
                self.pharmaDatabase = try PharmaDatabase(url: databaseFile)
                if let version = try self.pharmaDatabase?.version() {
                    self.updater.currentVersion = version
                }
            }
        } catch {
            monitor.error(error, context: .pharma)

            // This case can happen if the db adapter was updated via app update
            // but the user still has an older db on his device which is now incompatible ...
            if case PharmaDatabase.SchemaValidationError.schemaMinorVersionMismatch = error {
                do {
                    // We do this to avoid constant logging of "non fatal" errors to firebase
                    // for as long as the user does not update his db ...
                    try Self.removeCurrentDatabase(in: workingDirectory)
                } catch {
                    monitor.error(error, context: .pharma)
                }
            }
        }
    }

    var isBackgroundUpdatesEnabled: Bool {
        get {
            storage.get(for: .isPharmaBackgroundUpdatesEnabled) ?? false
        }
        set {
            storage.store(newValue, for: .isPharmaBackgroundUpdatesEnabled)
            trackingProvider.track(.libraryUpdateSettingsToggled(isBackgroundUpdatesEnabled: isBackgroundUpdatesEnabled, libraryType: .pharma))
        }
    }

    func checkForUpdate() throws {
        try checkForUpdate(install: false, type: .manual)
    }

    func startManualUpdate() throws {
        try checkForUpdate(install: true, type: .manual)
    }

    func startAutomaticUpdate() throws {
        try checkForUpdate(install: true, type: .automatic)
    }

    func application(_ application: UIApplicationType, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            try startAutomaticUpdate()
        } catch {
            monitor.error(error, context: .pharma)
        }
        return true
    }

    func deleteDatabase() throws {
        trackingProvider.track(.pharmaOfflineDeleteConfirmed(databaseVersion: updater.currentVersion.stringRepresentation))

        updater.cancel()
        try Self.removeFiles(in: Self.databaseDirectory(in: workingDirectory))
        self.pharmaDatabase = nil
        self.updater.currentVersion = Version(major: PharmaDatabase.supportedMajorSchemaVersion, minor: 0, patch: 0)
        try checkForUpdate() // -> will update the services state properly, before this it's out of sync
    }

    /// This is only used inside the `Developer Overlay` for debugging purposes.
    var pharmaDBVersion: Version {
        get {
            updater.currentVersion
        }
        set {
            updater.currentVersion = newValue
        }
    }
}

private extension PharmaDatabaseApplicationService {

    func checkForUpdate(install: Bool, type: PharmaDatabaseUpdateType) throws {

        guard queue.operations.isEmpty else {
            throw PharmaDatabaseApplicationServiceError.busy
            monitor.error(PharmaDatabaseApplicationServiceError.busy, context: .pharma)
        }

        let isUserTriggeredUpdate = (type == .manual)
        let isFirstInstall = !FileManager.default.fileExists(atPath: self.databaseFile.path)
        var availableUpdate: PharmaUpdate?
        queue.addOperation { [weak self] in
            guard let self = self else { return }

            do {
                self.state = .checking
                availableUpdate = try self.check(isUserTriggeredUpdate: isUserTriggeredUpdate)

                // We can stop here already if the operation is only supposed to check for an update
                guard install else {
                    self.state = .idle(error: nil, availableUpdate: availableUpdate, type: type)
                    return
                }

                // Automatic updates only happen on top of an alrady existing database
                // Only exception: The user triggered the update manually
                let isDatabaseExisting = FileManager.default.fileExists(atPath: self.databaseFile.path)
                let isUserTriggeredInstallation = (install && isUserTriggeredUpdate)
                guard isDatabaseExisting || isUserTriggeredInstallation || self.isBackgroundUpdatesEnabled else {
                    self.state = .idle(error: .noDatabaseToUpdate, availableUpdate: availableUpdate, type: type)
                    return
                }

                // Background updates are only allowed if the user enabled them via settings
                let isBackgroundUpdateAndBackgroundUpdatesAreEnabled = (type == .automatic && self.isBackgroundUpdatesEnabled)
                let isUpdateAllowed = isBackgroundUpdateAndBackgroundUpdatesAreEnabled || isUserTriggeredUpdate
                guard isUpdateAllowed else {
                    self.state = .idle(error: .updateNotAllowed, availableUpdate: availableUpdate, type: type)
                    return
                }

                guard let update = availableUpdate else {
                    self.state = .idle(error: nil, availableUpdate: nil, type: type)
                    return
                }
                let event = Tracker.Event.Library.libUpdateAvailable(isUpdateUserTriggered: isUserTriggeredUpdate, newLibraryVersion: update.version.stringRepresentation, libraryType: .pharma)
                self.trackingProvider.track(event)

                let fileURL = try self.update(isUserTriggeredUpdate: isUserTriggeredUpdate) { self.state = .downloading(update: update, progress: $0) }
                self.state = .installing
                try self.install(update: fileURL)

                self.state = .idle(error: nil, availableUpdate: nil, type: type)
                self.trackingProvider.track(.libraryUpdateCompleted(isFirstInstall: isFirstInstall, newLibraryVersion: update.version.stringRepresentation, libraryType: .pharma))
            } catch {
                self.state = .idle(error: PharmaDatabaseApplicationServiceError(error: error), availableUpdate: availableUpdate, type: type)
            }
        }
    }
}

private extension PharmaDatabaseApplicationService {

    func check(isUserTriggeredUpdate: Bool) throws -> PharmaUpdate? {
        self.trackingProvider.track(.libUpdateCheckStart(isUpdateUserTriggered: isUserTriggeredUpdate, libraryType: .pharma))

        // Forcing this to sync to make the block operation in checkForUpdate(install) more readable ...
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<PharmaUpdate?, PharmaUpdaterError>! // swiftlint:disable:this implicitly_unwrapped_optional
        updater.checkForUpdate { result = $0; semaphore.signal() }
        semaphore.wait()

        do {
            return try result.get()
        } catch {
            self.trackingProvider.track(.libUpdateCheckFailed(isUpdateUserTriggered: isUserTriggeredUpdate, libraryType: .pharma, error: error))
            throw error
        }
    }

    func update(isUserTriggeredUpdate: Bool, progress: @escaping (Double) -> Void) throws -> URL {
        self.trackingProvider.track(.libraryUpdateStarted(isUpdateUserTriggered: isUserTriggeredUpdate, libraryType: .pharma))

        // Forcing this sync to make the block operation in checkForUpdate(updateType:install) more readable ...
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<URL, Error>! // swiftlint:disable:this implicitly_unwrapped_optional
        updater.update(isUserTriggeredUpdate: isUserTriggeredUpdate, progressHandler: progress) {
            do {
                // Move the file away already to prevent it being deleted by the updater
                // once this closure has finished ...
                let sourceURL = try $0.get()
                let targetURL = try self.storeTemporaryily(source: sourceURL)
                result = .success(targetURL)
            } catch {
                result = .failure(error)
            }
            semaphore.signal()
        }
        semaphore.wait()
        return try result.get()
    }

    func install(update fromURL: URL) throws {
        let isFirstInstall = !FileManager.default.fileExists(atPath: self.databaseFile.path)
        self.trackingProvider.track(.libraryInstallStarted(isFirstInstall: isFirstInstall, libraryType: .pharma))

        do {
            // Already dummy init the db here before we start moving things around to make sure its valid
            // The DB wrapper runs a bunch of validations on init
            // If something goes wrong we can cancel out here already
            _ = try PharmaDatabase(url: fromURL)

            if FileManager.default.fileExists(atPath: databaseFile.path) {
                try FileManager.default.removeItem(at: databaseFile)
            }
            try FileManager.default.moveItem(at: fromURL, to: databaseFile)
            let pharmaDatabase = try PharmaDatabase(url: databaseFile)
            self.pharmaDatabase = pharmaDatabase

            // Next update will attempt to update from this version ...
            self.updater.currentVersion = try pharmaDatabase.version()

            trackingProvider.track(.libraryInstallCompleted(isFirstInstall: isFirstInstall, newLibraryVersion: self.updater.currentVersion.stringRepresentation, libraryType: .pharma))
        } catch {
            self.trackingProvider.track(.libraryInstallFailed(isFirstInstall: isFirstInstall, libraryType: .pharma, error: error))
            throw error
        }
    }

    func storeTemporaryily(source url: URL) throws -> URL {
        try Self.removeTemporaryFiles(in: workingDirectory)
        try FileManager.default.moveItem(at: url, to: temporaryFile)
        return temporaryFile
    }
}

// MARK: - File management and path building

// Filetree looks like below during updates
// Every file (except the one in pharmaDatabaseApplicationService)
// is removed once the update is finished
//
//  /Library/ => (or whichever working directory)
//  |
//  * - Pharma
//      |
//      * - Database
//      |   |
//      |   * - 4 (compatible major version)
//      |       |
//      |       * - pharmaDatabase.sqlite => (once in use by the service) (step 4)
//      |
//      * - Temporary
//      |   |
//      |   * - pharmaDatabase.sqlite => (directly after updater finished) (step 3)
//      |
//      * - Updater
//          |
//          * - pharma_4.0.1618099215.zip => (after downloaded from server) (step 1)
//          |
//          * - pharma.db => (after unzipping) (step 2)

extension PharmaDatabaseApplicationService {

    static func root(in directory: URL) -> URL {
        directory
            .appendingPathComponent("Pharma")
    }

    static func temporaryDirectory(in directory: URL) -> URL {
        Self.root(in: directory)
            .appendingPathComponent("Temporary")
    }

    static func temporaryFilename(in directory: URL) -> URL {
        Self.temporaryDirectory(in: directory)
            .appendingPathComponent(Self.databaseFilename(), isDirectory: false)
    }

    static func databaseDirectory(in directory: URL) -> URL {
        Self.root(in: directory)
            .appendingPathComponent("Database")
            .appendingPathComponent(String(PharmaDatabase.supportedMajorSchemaVersion))
    }

    static func databaseFilename() -> String {
        "pharmaDatabase.sqlite"
    }

    static func pharmaDatabaseFileURL(in directory: URL) -> URL {
        Self.databaseDirectory(in: directory)
            .appendingPathComponent(Self.databaseFilename(), isDirectory: false)
    }

    static func createDirectories(in directory: URL) throws {
        let urls = [
            Self.root(in: directory),
            Self.temporaryDirectory(in: directory),
            Self.databaseDirectory(in: directory)
        ]
        for url in urls {
            if !FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            }
        }
    }

    static func removeOutdatedDatabaseVersions(in directory: URL) throws {
        for major in 0..<PharmaDatabase.supportedMajorSchemaVersion {
            let url = Self.databaseDirectory(in: directory).deletingLastPathComponent().appendingPathComponent(String(major))
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
        }
    }

    static func removeCurrentDatabase(in directory: URL) throws {
        let url = Self.databaseDirectory(in: directory).deletingLastPathComponent().appendingPathComponent(String(PharmaDatabase.supportedMajorSchemaVersion))
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }

    static func removeTemporaryFiles(in directory: URL) throws {
        try Self.removeFiles(in: Self.temporaryDirectory(in: directory))
    }

    static func removeFiles(in directory: URL) throws {
        let urls = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        for url in urls {
            try FileManager.default.removeItem(at: url)
        }
    }
}
