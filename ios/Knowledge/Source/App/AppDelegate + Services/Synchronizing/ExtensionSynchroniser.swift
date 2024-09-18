//
//  ExtensionSynchroniser.swift
//  Knowledge
//
//  Created by Silvio Bulla on 31.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

final class ExtensionSynchroniser: Synchronizer {

    private let extensionRepository: ExtensionRepositoryType
    private let learningCardClient: LearningCardLibraryClient
    private let storage: Storage
    private let trackingProvider: TrackingType
    @Inject private var monitor: Monitoring
    private var extensionsDidChangeNotificationObserver: NSObjectProtocol?

    private var extensionsEndCursor: PaginationCursor? {
        get {
            storage.get(for: .extensionsSynchronizerEndCursor)
        }
        set {
            storage.store(newValue, for: .extensionsSynchronizerEndCursor)
        }
    }

    init(extensionRepository: ExtensionRepositoryType = resolve(), learningCardClient: LearningCardLibraryClient = resolve(), storage: Storage = resolve(tag: .default), trackingProvider: TrackingType = resolve()) {
        self.extensionRepository = extensionRepository
        self.learningCardClient = learningCardClient
        self.storage = storage
        self.trackingProvider = trackingProvider

        extensionsDidChangeNotificationObserver = NotificationCenter.default.observe(for: ExtensionsDidChangeNotification.self, object: extensionRepository, queue: .main) { [weak self] _ in
            guard let self = self,
                !self.extensionRepository.extensionsToBeUploaded().isEmpty else { return }
            NotificationCenter.default.post(SynchronizerNeedsSynchronization(synchronizer: self), sender: self)
        }
    }

    func synchronize(_ completion: @escaping (SynchronizationResult) -> Void) {
        monitor.debug("Starting extensions synchronisation.", context: .synchronization)

        uploadExtensions { [weak self] updateExtensionsSynchronizationResult in
            guard let self = self else { return }

            switch updateExtensionsSynchronizationResult {
            case .updated: self.downloadExtensions(didAlreadySynchronizeData: true, completion)
            case .notUpdated: self.downloadExtensions(didAlreadySynchronizeData: false, completion)
            case .failed: completion(.failed)
            }
        }
    }

    func removeAllDataFromLocalStorage() {
        extensionsEndCursor = nil
        extensionRepository.removeAllDataFromLocalStorage()
    }

    private func uploadExtensions(_ completion: @escaping (SynchronizationResult) -> Void) {
        let extensions = extensionRepository.extensionsToBeUploaded()

        guard !extensions.isEmpty else { return completion(.notUpdated) }

        uploadExtension(extensions: extensions) { result in
            switch result {
            case .success:
                completion(.updated)
            case .failure:
                completion(.failed)
            }
        }
    }

    private func uploadExtension(extensions: [Extension], _ completion: @escaping(Result<Void, Error>) -> Void) {
        guard let firstExtension = extensions.first else { return completion(.success(())) }

        learningCardClient.updateExtension(section: firstExtension.section, text: firstExtension.note) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.uploadExtension(extensions: Array(extensions.dropFirst()), completion)
            case .failure(let error):
                self.monitor.error(ExtensionSynchroniserError.uploadFailed(error), context: .synchronization)
                completion(.failure(error))
            }
        }
    }

    private func downloadExtensions(didAlreadySynchronizeData: Bool, _ completion: @escaping (SynchronizationResult) -> Void) {
        learningCardClient.getCurrentUserExtensions(after: extensionsEndCursor) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(nil):
                if didAlreadySynchronizeData {
                    completion(.updated)
                } else {
                    completion(.notUpdated)
                }
            case .success(let page):
                guard let page = page else { completion(.notUpdated); return }
                self.extensionsEndCursor = page.nextPage
                page.elements.forEach { self.extensionRepository.set(ext: $0) }
                if page.hasNextPage {
                    self.downloadExtensions(didAlreadySynchronizeData: true, completion)
                } else {
                    completion(.updated)
                }
            case .failure(let error):
                self.monitor.error(ExtensionSynchroniserError.downloadFailed(error), context: .synchronization)
                completion(.failed)
            }
        }
    }
}

extension ExtensionSynchroniser {
    enum ExtensionSynchroniserError: Error {
        case uploadFailed(Error)
        case downloadFailed(Error)
    }
}
