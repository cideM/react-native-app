//
//  SharedExtensionSynchronizer.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 29.04.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

final class SharedExtensionSynchronizer: Synchronizer {
    private let learningCardClient: LearningCardLibraryClient
    private let storage: Storage
    private let sharedExtensionRepository: SharedExtensionRepositoryType
    private let trackingProvider: TrackingType
    @Inject private var monitor: Monitoring

    init(learningCardClient: LearningCardLibraryClient = resolve(), storage: Storage = resolve(tag: .default), sharedExtensionRepository: SharedExtensionRepositoryType = resolve(), trackingProvider: TrackingType = resolve()) {
        self.learningCardClient = learningCardClient
        self.storage = storage
        self.sharedExtensionRepository = sharedExtensionRepository
        self.trackingProvider = trackingProvider
    }

    func synchronize(_ completion: @escaping (SynchronizationResult) -> Void) {
        monitor.debug("Starting shared extensions synchronisation.", context: .synchronization)

        updateUsersWhoShareExtensionsWithCurrentUser { [weak self] synchronizationResult in
            guard let self = self else { return }

            switch synchronizationResult {
            case .updated, .notUpdated:
                self.updateSharedExtensions(for: self.sharedExtensionRepository.users, completion: completion)
            case .failed:
                completion(synchronizationResult)
            }
        }
    }

    func removeAllDataFromLocalStorage() {
        sharedExtensionRepository.users.forEach {
            storage.store(nil as String?, for: .userSharedExtensionsEndCursor($0.identifier))
        }
        sharedExtensionRepository.removeAllDataFromLocalStorage()
    }

    private func updateUsersWhoShareExtensionsWithCurrentUser(completion: @escaping (SynchronizationResult) -> Void) {
        learningCardClient.getUsersWhoShareExtensionsWithCurrentUser { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let users):
                self.sharedExtensionRepository.set(users: users)
                completion(.updated)
            case .failure(let error):
                self.monitor.error(SharedExtensionSynchronizerError.failedToUpdateUsers(error), context: .synchronization)
                completion(.failed)
            }
        }
    }

    private func updateSharedExtensions(for user: User, after: PaginationCursor?, completion: @escaping (SynchronizationResult) -> Void) {
        learningCardClient.getExtensions(for: user.identifier, after: after) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let page):
                guard let page = page else { return completion(.notUpdated) }

                page.elements.forEach { self.sharedExtensionRepository.add(ext: $0, for: user) }

                if page.hasNextPage {
                    self.updateSharedExtensions(for: user, after: page.nextPage, completion: completion)
                } else {
                    self.storage.store(page.nextPage, for: .userSharedExtensionsEndCursor(user.identifier))
                    completion(.updated)
                }

            case .failure(let error):
                self.monitor.error(SharedExtensionSynchronizerError.failedToUpdateSharedExtensions(error), context: .synchronization)
                completion(.failed)
            }
        }
    }

    private func updateSharedExtensions(for users: [User], completion: @escaping (SynchronizationResult) -> Void) {
        guard !users.isEmpty else { return completion(.notUpdated) }

        let group = DispatchGroup()
        let queue = DispatchQueue(label: "Friends Synchronization Queue")
        let semaphore = DispatchSemaphore(value: 0)
        var synchronizationResults: [SynchronizationResult] = []

        queue.async { [weak self] in
            guard let self = self else { return }

            for user in users {
                group.enter()
                self.updateSharedExtensions(for: user, after: self.storage.get(for: .userSharedExtensionsEndCursor(user.identifier))) { synchronizationResult in
                    synchronizationResults.append(synchronizationResult)
                    semaphore.signal()
                    group.leave()
                }
                semaphore.wait()
            }
        }

        group.notify(queue: queue) {
            let synchronizationResult: SynchronizationResult

            if synchronizationResults.contains(.updated) {
                synchronizationResult = .updated
            } else if synchronizationResults.contains(.notUpdated) {
                synchronizationResult = .notUpdated
            } else {
                synchronizationResult = .failed
            }

            completion(synchronizationResult)
        }
    }
}

extension SharedExtensionSynchronizer {
    enum SharedExtensionSynchronizerError: Error {
        case failedToUpdateUsers(Error)
        case failedToUpdateSharedExtensions(Error)
    }
}
