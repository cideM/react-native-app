//
//  PharmaUpdater.swift
//  Knowledge
//
//  Created by Silvio Bulla on 30.03.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import Common

import Domain
import Networking
import PharmaDatabase

/// @mockable
protocol PharmaUpdaterType {

    static var dbFilenameInArchive: String { get }

    var currentVersion: Version { get set }

    func checkForUpdate(completion: @escaping (Result<PharmaUpdate?, PharmaUpdaterError>) -> Void)
    func update(isUserTriggeredUpdate: Bool, progressHandler: @escaping (Double) -> Void, completionHandler: @escaping (Result<URL, PharmaUpdaterError>) -> Void)
    func cancel()
}

final class PharmaUpdater: PharmaUpdaterType {

    static let dbFilenameInArchive = "pharma.db"

    var currentVersion: Version

    private let workingDirectory: URL
    private let pharmaDownloader: FileDownloaderType
    private let unzipper: UnzipperType
    private let pharmaClient: PharmaClient
    private let trackingProvider: TrackingType
    private let logger: Monitoring = resolve()

    init(workingDirectory: URL, unzipper: UnzipperType, pharmaDownloader: FileDownloaderType, currentVersion: Version, pharmaClient: PharmaClient = resolve(), trackingProvider: TrackingType = resolve()) throws {
        self.workingDirectory = try PharmaUpdater.workingDirectory(in: workingDirectory)
        self.unzipper = unzipper
        self.pharmaDownloader = pharmaDownloader
        self.currentVersion = currentVersion
        self.pharmaClient = pharmaClient
        self.trackingProvider = trackingProvider

        if !FileManager.default.fileExists(atPath: self.workingDirectory.path) {
            try FileManager.default.createDirectory(at: self.workingDirectory, withIntermediateDirectories: true)
        }

        // Making sure we don't have any leftover from previews processes on the updater folder.
        // Example: Deleting any leftover from canceling a running unzipping process.
        deleteTemporaryFiles(at: workingDirectory)
    }

    func checkForUpdate(completion: @escaping (Result<PharmaUpdate?, PharmaUpdaterError>) -> Void) {
        pharmaClient.getPharmaDatabases(for: currentVersion.major) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let pharmaDatabases):
                let pharmaUpdate = pharmaDatabases
                    .filter({ $0.version > self.currentVersion })
                    .filter({ $0.version.major >= PharmaDatabase.supportedMajorSchemaVersion })
                    .filter({ $0.version.minor >= PharmaDatabase.supportedMinorSchemaVersion })
                    .max(by: { $0.version < $1.version })
                completion(.success(pharmaUpdate))
            case .failure(let error):
                completion(.failure(.underlyingError(error: error)))
            }
        }
    }

    func update(isUserTriggeredUpdate: Bool, progressHandler: @escaping (Double) -> Void, completionHandler: @escaping (Result<URL, PharmaUpdaterError>) -> Void) {
        checkForUpdate { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let pharmaUpdate):
                guard let pharmaUpdate = pharmaUpdate else { return completionHandler(.failure(.underlyingError())) }

                let filename = pharmaUpdate.url.lastPathComponent
                guard !filename.isEmpty else {
                    completionHandler(.failure(.invalidFilenameInDatabaseDownloadURL(urlString: pharmaUpdate.url.absoluteString)))
                    return
                }
                let downloadDestinationFileURL = self.workingDirectory.appendingPathComponent(filename)

                let event = Tracker.Event.Library.libraryDownloadStarted(isUpdateUserTriggered: isUserTriggeredUpdate, newLibraryVersion: pharmaUpdate.version.stringRepresentation, libraryType: .pharma)
                self.trackingProvider.track(event)

                self.pharmaDownloader.download(from: pharmaUpdate.url, to: downloadDestinationFileURL) { progress in
                    progressHandler(progress)
                } completion: { result in

                    switch result {
                    case .success:
                        self.trackingProvider.track(.libraryDownloadCompleted(libraryType: .pharma))

                        let isFirstInstall = self.currentVersion == Version(major: PharmaDatabase.supportedMajorSchemaVersion, minor: 0, patch: 0)
                        self.trackingProvider.track(.libraryUnzipStarted(isFirstInstall: isFirstInstall, libraryType: .pharma))

                        self.unzipAtPath(downloadDestinationFileURL, to: self.workingDirectory) { result in
                            switch result {
                            case .success:
                                self.trackingProvider.track(.libraryUnzipCompleted(isFirstInstall: isFirstInstall, libraryType: .pharma))

                                let url = self.workingDirectory.appendingPathComponent(Self.dbFilenameInArchive)
                                if FileManager.default.fileExists(atPath: url.path) {
                                    completionHandler(.success(url))
                                } else {
                                    completionHandler(.failure(.unexpectedPharmaDatabaseFilenameInArchive))
                                }
                            case .failure(let error):
                                self.trackingProvider.track(.libraryUnzipFailed(isFirstInstall: isFirstInstall, libraryType: .pharma, error: error))
                                completionHandler(.failure(error))
                            }
                        }
                    case .failure(let error):
                        self.trackingProvider.track(.libraryDownloadFailed(libraryType: .pharma, error: error))

                        switch error {
                        case FileDownloaderError.network(underlying: let error):
                            if (error as NSError).code == NSURLErrorCancelled {
                                completionHandler(.failure(.canceled))
                            }
                        default:
                            completionHandler(.failure(.downloaderError(error)))
                        }
                    }
                    self.deleteTemporaryFiles(at: self.workingDirectory)
                }
            case .failure(let error):
                completionHandler(.failure(.underlyingError(error: error)))
            }
        }
    }

    func cancel() {
        pharmaDownloader.cancel()
    }

    private func unzipAtPath(_ path: URL, to: URL, completion: @escaping (Result<Void, PharmaUpdaterError>) -> Void) {
        unzipper.unzipFileAtPath(path.path, toDestination: workingDirectory.path) { result in
            switch result {
            case .success: completion(.success(()))
            case .failure(let error): completion(.failure(.unzippingFailed(error)))
            }
        }
    }

    private func deleteTemporaryFiles(at url: URL) {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: workingDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            logger.error(error, context: .pharma)
        }
    }

    static func workingDirectory(in directory: URL) throws -> URL {
        // This func is also used during testing ...
        directory.appendingPathComponent("Updater")
    }
}
