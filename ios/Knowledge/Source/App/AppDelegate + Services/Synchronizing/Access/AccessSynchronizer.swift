//
//  AccessSynchronizer.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 27.05.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import DateToolsSwift
import Domain
import Networking

final class AccessSynchronizer: Synchronizer {
    private let accessRepository: AccessRepositoryType
    private let learningCardClient: LearningCardLibraryClient
    private let storage: Storage
    private let trackingProvider: TrackingType
    @Inject private var monitor: Monitoring
    private var lastSynchronizationDate: Date? {
        get {
            storage.get(for: .accessesLastSynchronizationDate)
        }
        set {
            storage.store(newValue, for: .accessesLastSynchronizationDate)
        }
    }

    init(accessRepository: AccessRepositoryType = resolve(), learningCardClient: LearningCardLibraryClient = resolve(), storage: Storage = resolve(tag: .default), trackingProvider: TrackingType = resolve()) {
        self.accessRepository = accessRepository
        self.learningCardClient = learningCardClient
        self.storage = storage
        self.trackingProvider = trackingProvider
    }

    func synchronize(_ completion: @escaping (SynchronizationResult) -> Void) {
        monitor.debug("Starting target accesses synchronisation.", context: .synchronization)

        learningCardClient.getTargetAccesses { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let targetAccesses):
                self.accessRepository.set(accesses: targetAccesses)

                if let lastSynchronizationDate = self.lastSynchronizationDate, lastSynchronizationDate.days(from: Date()) <= -1 {
                    self.monitor.debug("Target access syncronization will complete with .notUpdated because the last update was less than a day ago", context: .synchronization)
                    completion(.notUpdated)
                } else {
                    self.monitor.debug("Target access syncronization will complete with .updated", context: .synchronization)
                    self.lastSynchronizationDate = Date()
                    completion(.updated)
                }
            case .failure(let error):
                self.monitor.error(AccessSynchronizerError.downloadFailed(error), context: .synchronization)
                completion(.failed)
            }
        }
    }

    func removeAllDataFromLocalStorage() {
        lastSynchronizationDate = nil
    }
}

extension AccessSynchronizer {
    enum AccessSynchronizerError: Error {
        case downloadFailed(Error)
    }
}
