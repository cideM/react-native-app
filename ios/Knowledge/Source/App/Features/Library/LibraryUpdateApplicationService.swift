//
//  LibraryUpdateApplicationService.swift
//  Knowledge
//
//  Created by CSH on 20.01.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking
import UIKit
import Localization
import DateToolsSwift

/// @mockable
protocol LibraryUpdateApplicationServiceType: LibraryUpdaterType, ApplicationService {}

final class LibraryUpdateApplicationService: LibraryUpdateApplicationServiceType {

    var isBackgroundUpdatesEnabled: Bool {
        get {
            storage.get(for: .isLibraryBackgroundUpdatesEnabled) ?? true
        }
        set {
            storage.store(newValue, for: .isLibraryBackgroundUpdatesEnabled)
            monitor.info("isBackgroundUpdatesEnabled changed: \(isBackgroundUpdatesEnabled)", context: .library)
            trackingProvider.track(.libraryUpdateSettingsToggled(isBackgroundUpdatesEnabled: isBackgroundUpdatesEnabled, libraryType: .articles))
        }
    }

    private(set) var state: LibraryUpdaterState {
        didSet {
            NotificationCenter.default.post(LibraryUpdaterStateDidChangeNotification(oldValue: oldValue, newValue: state), sender: self)
            monitor.info("State changed: \(state)", context: .library)
            if case .downloading = oldValue, case .downloading = state {
                // don't log download progress as debug all the time
            } else {
                storage.store(state, for: .libraryUpdaterState)
                monitor.debug("State changed: \(state)", context: .library)
            }
        }
    }

    private let learningCardClient: LearningCardLibraryClient
    private let storage: Storage
    private let libraryRepository: LibraryRepositoryType
    private let accessRepository: AccessRepositoryType
    @Inject private var monitor: Monitoring

    private var backgroundCompletionHandler: (() -> Void)?
    private let trackingProvider: TrackingType

    init(learningCardClient: LearningCardLibraryClient = resolve(),
         storage: Storage,
         trackingProvider: TrackingType = resolve(),
         libraryRepository: LibraryRepositoryType = resolve(),
         accessRepository: AccessRepositoryType = resolve(),
         cleaner: LibraryUpdaterLegacyCleanerType = resolve(),
         baseFolder: URL = resolve(tag: .libraryRoot)) {
        self.learningCardClient = learningCardClient
        self.storage = storage
        self.libraryRepository = libraryRepository
        self.accessRepository = accessRepository
        self.trackingProvider = trackingProvider

        self.state = storage.get(for: .libraryUpdaterState) ?? .upToDate
        self.learningCardClient.downloadDelegate = self
        // This just skips the creation of the directory if it already exists ...
        try? FileManager.default.createDirectory(at: baseFolder, withIntermediateDirectories: true)

        cleaner.cleanup()
    }

    private var stateIsRestored = false
    private func restoreState() {
        guard !stateIsRestored else { return }
        switch state {
        case .upToDate:
            break
        case .checking:
            state = .upToDate
        case .installing(let libraryUpdate, let libraryTmpFileName):
            performInstallation(libraryUpdate: libraryUpdate, libraryZipUrl: FileManager.default.temporaryDirectory.appendingPathComponent(libraryTmpFileName))
        case .downloading(let update, _, let isUserTriggered):
            performUpdate(libraryUpdate: update, isUserTriggered: isUserTriggered)
        case .failed:
            state = .upToDate
        }
        stateIsRestored = true
    }

    func initiateUpdate(isUserTriggered: Bool) {
        restoreState()
        switch state {
            // if the state is upToDate or failed, all is fine
        case .upToDate, .failed: break
            // otherwise we don't want to start a new process, we just want to update the isUserTriggered parameter
        case .checking(isUserTriggered: let wasUserTriggered):
            state = .checking(isUserTriggered: isUserTriggered || wasUserTriggered)
            return
        case .downloading(let update, let progress, isUserTriggered: let wasUserTriggered):
            state = .downloading(update, progress, isUserTriggered: isUserTriggered || wasUserTriggered)
            return
        case .installing:
            return
        }

        monitor.info("Started checking for an update. Current version: \(libraryRepository.library.metadata.versionId)", context: .library)

        state = .checking(isUserTriggered: isUserTriggered)
        trackingProvider.track(.libUpdateCheckStart(isUpdateUserTriggered: isUserTriggered, libraryType: .articles))

        updateLibraryIfNeeded(isUserTriggered: isUserTriggered)

    }

    private func updateLibraryIfNeeded(isUserTriggered: Bool) {
        learningCardClient.checkForLibraryUpdate(currentLibrary: libraryRepository.library.metadata) { [weak self] result in
            guard let self = self else { return }
            self.trackingProvider.track(.libraryUpdateStarted(isUpdateUserTriggered: isUserTriggered, libraryType: .articles))

            switch result {
            case .success(let libraryUpdate):
                if let libraryUpdate = libraryUpdate {
                    self.monitor.debug("Update available: \(libraryUpdate.version)", context: .library)

                    let version = libraryUpdate.version
                    let mode = libraryUpdate.updateMode
                    let event = Tracker.Event.Library.libUpdateAvailable(isUpdateUserTriggered: isUserTriggered, newLibraryVersion: String(version), updateMode: mode, libraryType: .articles)
                    self.trackingProvider.track(event)
                    self.downloadUpdateIfNeeded(libraryUpdate: libraryUpdate, isUserTriggered: isUserTriggered)

                } else {
                    self.monitor.debug("No update available.", context: .library)
                    self.state = .upToDate
                }
            case .failure(let error):
                self.monitor.warning("Failed to check for an update with error: \(error)", context: .library)
                self.trackingProvider.track(.libUpdateCheckFailed(isUpdateUserTriggered: isUserTriggered, libraryType: .articles, error: error))
                self.state = .upToDate
            }
        }
    }

    private func downloadUpdateIfNeeded(libraryUpdate: LibraryUpdate,
                                        isUserTriggered: Bool) {

        if isUserTriggered {
            // If: Update was manually triggered by the user ->
            // Then: library update should be downloaded
            self.downloadUpdate(libraryUpdate: libraryUpdate,
                          isUserTriggered: isUserTriggered)

        } else if !isBackgroundUpdatesEnabled {
            // If: the update was NOT triggered by the user
            //     AND automatic updates are not enabled
            // Then: don't download the update automatically
            let error = LibraryUpdateError.backgroundUpdatesNotAllowed
            self.state = .failed(libraryUpdate, error)

            let event = Tracker.Event.Library.libUpdateCheckFailed(
                isUpdateUserTriggered: isUserTriggered,
                newLibraryVersion: String(libraryUpdate.version),
                updateMode: libraryUpdate.updateMode,
                libraryType: .articles,
                error: error)
            self.trackingProvider.track(event)

        } else {
            // If: the update was NOT triggered by the user
            //     AND automatic updates are enabled
            // Then: check for existance of library_archive permission
            //         before starting the download automatically
            self.downloadUpdateIfAuthorized(libraryUpdate: libraryUpdate,
                                      isUserTriggered: isUserTriggered)
        }
    }

    private func downloadUpdateIfAuthorized(libraryUpdate: LibraryUpdate,
                                            isUserTriggered: Bool) {

        func fail() {
            state = .failed(libraryUpdate, LibraryUpdateError.backgroundUpdatesNotAllowed)
        }

        accessRepository.getAccess(for: AccessTargets.libraryArchive, completion: { [weak self] result in
            guard (try? result.get()) != nil else { return fail() }
            self?.accessRepository.getAccess(for: AccessTargets.learningCard, completion: { [weak self] result in
                guard (try? result.get()) != nil else { return fail() }
                self?.downloadUpdate(libraryUpdate: libraryUpdate, isUserTriggered: isUserTriggered)
            })
        })
    }

    private func downloadUpdate(libraryUpdate: LibraryUpdate,
                                isUserTriggered: Bool) {

        self.state = .downloading(libraryUpdate, 0, isUserTriggered: isUserTriggered)

        let event = Tracker.Event.Library.libraryDownloadStarted(
            isUpdateUserTriggered: isUserTriggered,
            newLibraryVersion: String(libraryUpdate.version),
            updateMode: libraryUpdate.updateMode,
            libraryType: .articles)

        self.trackingProvider.track(event)
        self.performUpdate(libraryUpdate: libraryUpdate,
                           isUserTriggered: isUserTriggered)
    }

}

extension LibraryUpdateApplicationService: LibraryUpdaterType {

    private func performInstallation(libraryUpdate: LibraryUpdate, libraryZipUrl: URL, baseFolder: URL = resolve(tag: .libraryRoot)) {
        monitor.debug("Starting the Library installation", context: .library)
        state = .installing(libraryUpdate: libraryUpdate, libraryZipFileName: libraryZipUrl.lastPathComponent)
        trackingProvider.track(.libraryInstallStarted(isFirstInstall: false, libraryType: .articles))

        do {
            let library = try Library(with: libraryZipUrl)
            let newLibraryVersion = library.metadata.versionId
            trackingProvider.track(.libraryInstallCompleted(isFirstInstall: false, newLibraryVersion: String(newLibraryVersion), libraryType: .articles))

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.monitor.info("Successfully prepared library. Applying the library", context: .library)
                let oldLibraryUrl = self.libraryRepository.library.url

                library.move(toParent: baseFolder)
                self.libraryRepository.library = library

                try? FileManager.default.removeItem(at: oldLibraryUrl)

                self.trackingProvider.track(.libraryUpdateCompleted(isFirstInstall: false, newLibraryVersion: String(libraryUpdate.version), updateMode: libraryUpdate.updateMode, libraryType: .articles))
                self.state = .upToDate
            }
        } catch {
            monitor.warning("Installing lirary failed with error \(error.localizedDescription)", context: .library)
            self.trackingProvider.track(.libraryInstallFailed(isFirstInstall: false, libraryType: .articles, error: error))

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                try? FileManager.default.removeItem(at: libraryZipUrl)
                self.state = .failed(libraryUpdate, .invalidArchive(error))
            }
        }
    }

    private func performUpdate(libraryUpdate: LibraryUpdate, isUserTriggered: Bool) {
        monitor.info("Performing update started: \(libraryUpdate)", context: .library)
        learningCardClient.downloadFile(at: libraryUpdate.url, isUserInitiated: isUserTriggered, countOfBytesClientExpectsToReceive: Int64(truncatingIfNeeded: libraryUpdate.size))
    }
}

extension LibraryUpdateApplicationService: DownloadDelegate {
    func downloadClientDidMakeProgress(source: URL, progress: Double) {
        guard case let .downloading(downloadingLibraryUpdate, _, _) = state, downloadingLibraryUpdate.url == source else { return }

        if case let .downloading(_, _, isUserTriggered) = self.state {
            self.state = .downloading(downloadingLibraryUpdate, progress, isUserTriggered: isUserTriggered)
        } else {
            assertionFailure("Update progress got called with unexpected arguments")
        }
    }

    func downloadClientDidFinish(source: URL, destination: URL) {
        guard case let .downloading(downloadingLibraryUpdate, _, _) = state, downloadingLibraryUpdate.url == source else { return }
        monitor.debug("Download finished", context: .library)
        trackingProvider.track(.libraryDownloadCompleted(libraryType: .articles))

        // We need to move the file to our own tmp folder. Otherwise, the system will delete it right away
        let temporaryZipFile = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try FileManager.default.moveItem(at: destination, to: temporaryZipFile)
            performInstallation(libraryUpdate: downloadingLibraryUpdate, libraryZipUrl: temporaryZipFile)
        } catch {
            monitor.warning("Failed to move archive with error \(error)", context: .library)
            state = .failed(downloadingLibraryUpdate, .downloadFailed(error))
        }
    }

    func downloadClientDidFail(source: URL, error: Error) {
        guard case let .downloading(downloadingLibraryUpdate, _, _) = state, downloadingLibraryUpdate.url == source else { return }
        monitor.debug("Download failed with error: \(error)", context: .library)
        trackingProvider.track(.libraryDownloadFailed(libraryType: .articles, error: error))

        let error = error as NSError
        if error.code == NSURLErrorNotConnectedToInternet {
            self.state = .failed(downloadingLibraryUpdate, .notConnectedToTheInternet)
        } else {
            self.state = .failed(downloadingLibraryUpdate, .downloadFailed(error))
        }
    }

    func downloadClientDidFinishEventsForBackgroundURLSession() {
        monitor.debug("downloadClientDidFinishEventsForBackgroundURLSession", context: .library)

        // If the download just finished, we should make sure we switch
        // over to the .installing(url-of-the-zip-file) state
        backgroundCompletionHandler?()
    }
}

extension LibraryUpdateApplicationService: ApplicationService {
    func applicationDidBecomeActive(_ application: UIApplicationType) {
        storage.store(Date(), for: .mostRecentUserTriggeredAppLaunchDate)
    }

    func application(_ application: UIApplicationType, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // State will usually be ".inactive" at this point for a "non background fetch" launch
        // It will only be ".background" when the app was started by the system for a background fetch
        let state = application.applicationState

        // Update library, but under a bunch of preconditions ...
        switch state {
        case .active, .inactive:
            // User did start the app via springboard, always update library ...
            initiateUpdate(isUserTriggered: false)

        case .background:
            // This is a background fetch, only update if user was active within last 7 days ...
            let date: Date = storage.get(for: .mostRecentUserTriggeredAppLaunchDate) ?? .distantPast
            let shouldSkipUpdate = date.daysAgo > 7
            if shouldSkipUpdate {
                trackingProvider.track(.libraryUpdateSkipped(inactiveDays: date.daysAgo))
            } else {
                initiateUpdate(isUserTriggered: false)
            }
        @unknown default:
            break
        }
        return true
    }

    func application(_ application: UIApplicationType, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        backgroundCompletionHandler = completionHandler
    }
}
