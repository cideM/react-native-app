//
//  RemoteConfigSynchronizer.swift
//  Knowledge
//
//  Created by Merve Kavaklioglu on 25.01.21.
//  Copyright © 2021 AMBOSS GmbH. All rights reserved.
//

import DIKit

import Domain

public enum RemoteConfigSynchError: Error {
    case fetchFailed(_ error: Error?)
    case activationFailed(_ error: Error?)
    case noFetchYet(_ error: Error?)
    case fetchThrottled(_ error: Error?)
    case unknownError(_ error: Error?)
}

final class RemoteConfigSynchronizer: Synchronizer {

    @LazyInject private var remoteConfig: RemoteConfigType
    @Inject private var monitor: Monitoring

    func synchronize(_ completion: @escaping (SynchronizationResult) -> Void) {
        remoteConfig.fetch { [weak self] result in
            switch result {
            case .success:
                completion(.updated)
            case .failure(let failure):
                    switch failure {
                    case .activationFailed(let error):
                        self?.monitor.error(RemoteConfigSynchError.activationFailed(error), context: .synchronization)
                    case .fetchFailed(let error):
                        self?.monitor.error(RemoteConfigSynchError.fetchFailed(error), context: .synchronization)
                    case .noFetchYet(let error):
                        self?.monitor.error(RemoteConfigSynchError.noFetchYet(error), context: .synchronization)
                    case .fetchThrottled(let error):
                        self?.monitor.error(RemoteConfigSynchError.fetchThrottled(error), context: .synchronization)
                    case .unknownError(let error):
                        self?.monitor.error(RemoteConfigSynchError.unknownError(error), context: .synchronization)
                    }
                completion(.failed)
            }
        }
    }

    func removeAllDataFromLocalStorage() {}
}
