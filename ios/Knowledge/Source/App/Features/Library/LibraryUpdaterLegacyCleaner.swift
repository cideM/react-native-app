//
//  LibraryUpdaterLegacyCleaner.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 27.12.22.
//  Copyright © 2022 AMBOSS GmbH. All rights reserved.
//

import DIKit
import Foundation
import Domain

/// @mockable
protocol LibraryUpdaterLegacyCleanerType {
    func cleanup()
}

class LibraryUpdaterLegacyCleaner: LibraryUpdaterLegacyCleanerType {
    @Inject(tag: DIKitTag.URL.libraryRoot) private var baseFolder: URL
    @Inject private var monitor: Monitoring

    func cleanup() {
        cleanupLegacyLibraries()
        cleanupUnusedLibraries()
        cleanupTempFolder()
    }

    // Legacy Libraries are the ones before the non-unzipping libraries
    // This is here for legacy reasons when the library was still unzipped into the documents directory
    // We want to clean this up after the user updated to the version that uses the zip directly
    // We should remove this once enough time has passed ... (see this ticket: PHEX-997)
    func cleanupLegacyLibraries(libraryRepository: LibraryRepositoryType = resolve()) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let currentLibraryFilename = libraryRepository.library.url.lastPathComponent

        monitor.info("Will cleanup unused unzipped legacy libraries", context: .library)
        monitor.info("Current library is: \(currentLibraryFilename)", context: .library)

        do {
            let documentsDirectoryContent = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: [URLResourceKey.isDirectoryKey], options: FileManager.DirectoryEnumerationOptions.skipsSubdirectoryDescendants)
            for item in documentsDirectoryContent {
                if isLibraryDirectory(item) {
                    DispatchQueue.global(qos: .background).async { [weak self] in
                        self?.removeItem(at: item)
                        self?.monitor.info("Removed stale library at: \(item)", context: .library)
                    }
                }
            }
        } catch {
            monitor.warning("Could not cleanup unused unzipped legacy libraries. Failed with error: \(error)", context: .library)
        }
    }

    // If for any reason there is a library in the base folder, that is currently
    // not being used, then delete it
    func cleanupUnusedLibraries(libraryRepository: LibraryRepositoryType = resolve()) {
        let currentLibraryFilename = libraryRepository.library.url.lastPathComponent

        monitor.info("Will cleanup unused libraries", context: .library)
        monitor.info("Current library is: \(currentLibraryFilename)", context: .library)

        do {
            // Handle stale zip libraries ...
            let items = try FileManager.default.contentsOfDirectory(at: baseFolder, includingPropertiesForKeys: [.isRegularFileKey], options: [])
            for item in items {
                if currentLibraryFilename != item.lastPathComponent { // swiftlint:disable:this for_where
                    DispatchQueue.global(qos: .background).async { [weak self] in
                        self?.removeItem(at: item)
                        self?.monitor.info("Removed stale library at: \(item)", context: .library)
                    }
                }
            }

        } catch {
            monitor.warning("Could not cleanup unused libraries. Failed with error: \(error)", context: .library)
        }
    }

    // In older versions of the app we kept files
    // in the temp folder after they were not needed anymore
    // This function will simply delete all files older than 7 days
    func cleanupTempFolder() {
        do {
            try FileManager.default.removeItems(at: FileManager.default.temporaryDirectory, olderThan: 7.days)
        } catch {
            self.monitor.warning("Error when cleaning up the temp folder: \(error)", context: .library)
        }
    }

    private func isLibraryDirectory(_ directory: URL) -> Bool {
        FileManager.default.fileExists(atPath: directory.appendingPathComponent("lcmeta.json").path)
    }

    private func removeItem(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            self.monitor.warning("Failed to remove item at url \(url) with error: \(error)", context: .library)
        }
    }
}
