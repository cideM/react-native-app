//
//  ReadingsSynchronizer.swift
//  Knowledge
//
//  Created by Silvio Bulla on 08.09.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

final class ReadingsSynchronizer: Synchronizer {

    private let learningCardClient: LearningCardLibraryClient
    private let readingRepository: ReadingRepositoryType
    private let trackingProvider: TrackingType
    @Inject private var monitor: Monitoring

    init(learningCardClient: LearningCardLibraryClient = resolve(), readingRepository: ReadingRepositoryType = resolve(), trackingProvider: TrackingType = resolve()) {
        self.learningCardClient = learningCardClient
        self.readingRepository = readingRepository
        self.trackingProvider = trackingProvider
    }

    func synchronize(_ completion: @escaping (SynchronizationResult) -> Void) {
        monitor.debug("Starting readingsSynchronization", context: .synchronization)

        let readings = readingRepository.readingsToBeSynchronized()
        guard !readings.isEmpty else { return completion(.notUpdated) }

        learningCardClient.uploadReadings(readings) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.readingRepository.removeSynchronizedReadings()
                completion(.updated)
            case.failure(let error):
                self.monitor.error(ReadingsSynchronizerError.uploadFailed(error), context: .synchronization)
                completion(.failed)
            }
        }
    }

    func removeAllDataFromLocalStorage() {
        readingRepository.removeAllDataFromLocalStorage()
    }
}

extension ReadingsSynchronizer {
    enum ReadingsSynchronizerError: Error {
        case uploadFailed(Error)
    }
}
