//
//  KillSwitchSynchronizer.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 24.08.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

final class KillSwitchSynchronizer: Synchronizer {
    private let knowledgeClient: KnowledgeClient
    private let userDataRepository: UserDataRepositoryType
    private let killSwitchRepository: KillSwitchRepositoryType
    private let trackingProvider: TrackingType
    @LazyInject private var monitor: Monitoring

    init(
        userDataRepository: UserDataRepositoryType = resolve(),
        killSwitchRepository: KillSwitchRepositoryType = resolve(),
        knowledgeClient: KnowledgeClient = resolve(),
        trackingProvider: TrackingType = resolve()) {
        self.killSwitchRepository = killSwitchRepository
        self.userDataRepository = userDataRepository
        self.knowledgeClient = knowledgeClient
        self.trackingProvider = trackingProvider
    }

    func synchronize(_ completion: @escaping (SynchronizationResult) -> Void) {
        knowledgeClient.getDeprecationList { [weak self] result in
            guard let self = self else { return completion(.failed) }

            switch result {
            case .success(let deprecationItems):
                completion(self.killSwitchRepository.updateDeprecationStatus(with: deprecationItems) ? .updated : .notUpdated)
            case .failure(let error):
                self.monitor.error(KillSwitchSynchronizerError.downloadFailed(error), context: .synchronization)
                completion(.failed)
            }
        }
    }

    func removeAllDataFromLocalStorage() {}
}

extension KillSwitchSynchronizer {
    enum KillSwitchSynchronizerError: Error {
        case downloadFailed(Error)
    }
}
