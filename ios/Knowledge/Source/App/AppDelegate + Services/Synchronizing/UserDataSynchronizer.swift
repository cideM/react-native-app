//
//  UserDataSynchronizer.swift
//  Knowledge
//
//  Created by Mohamed Abdul Hameed on 12.03.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

// Note: This synchronizer right now only downloads stuff.
final class UserDataSynchronizer: Synchronizer {
    private let userDataClient: UserDataClient
    private let userDataRepository: UserDataRepositoryType
    private let featureFlagRepository: FeatureFlagRepositoryType
    private let trackingProvider: TrackingType
    @Inject private var monitor: Monitoring

    init(userDataClient: UserDataClient = resolve(), userDataRepository: UserDataRepositoryType = resolve(), featureFlagRepository: FeatureFlagRepositoryType = resolve(), trackingProvider: TrackingType = resolve()) {
        self.userDataClient = userDataClient
        self.userDataRepository = userDataRepository
        self.featureFlagRepository = featureFlagRepository
        self.trackingProvider = trackingProvider
    }

    func synchronize(_ completion: @escaping (SynchronizationResult) -> Void) {
        self.monitor.debug("User Data starting Synchronization", context: .synchronization)

        getCurrentUserData { [weak self] currentUserDataSyncResult in
            guard let self = self else { return }

            switch currentUserDataSyncResult {
            case .updated: self.getCurrentUserConfiguration(didAlreadySynchronizeData: true, completion)
            case .notUpdated, .failed: self.getCurrentUserConfiguration(didAlreadySynchronizeData: false, completion)
            }
        }
    }

    private func getCurrentUserData(_ completion: @escaping (SynchronizationResult) -> Void) {
        let oldUserStage = userDataRepository.userStage
        let oldStudyObjective = userDataRepository.studyObjective
        let oldFeatureFlags = featureFlagRepository.featureFlags

        userDataClient.getCurrentUserData(cachePolicy: .reloadIgnoringLocalCacheData) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let userData):
                self.userDataRepository.userStage = userData.stage
                self.userDataRepository.studyObjective = userData.studyObjective
                self.featureFlagRepository.featureFlags = userData.featureFlags
                self.userDataRepository.shouldUpdateTerms = userData.shouldUpdateTermsAndConditions

                if oldUserStage == userData.stage && oldStudyObjective == userData.studyObjective && oldFeatureFlags == userData.featureFlags {
                    self.monitor.debug("User Data finished Synchronization with no updates", context: .synchronization)
                    completion(.notUpdated)
                } else {
                    self.monitor.debug("User Data finished Synchronization with updates", context: .synchronization)
                    completion(.updated)
                }
            case .failure(let error):
                self.monitor.error(UserDataSynchronizerError.failedToFetchCurrentUserData(error), context: .synchronization)
                completion(.failed)
            }
        }
    }

    private func getCurrentUserConfiguration(didAlreadySynchronizeData: Bool, _ completion: @escaping (SynchronizationResult) -> Void) {
        let oldHasConfirmedHealthCareProfession = userDataRepository.hasConfirmedHealthCareProfession ?? false

        userDataClient.getUserHealthCareProfessionStatus { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let hasConfirmedHealthCareProfession):
                // It might happen, that the user already agreed to the disclaimer but the request (thats updating this state) is overlapping with this request.
                // Since setting this value back to "false" is not possible we just make sure we always take "true" here if it exists anywhere
                let newHasConfirmedHealthCareProfession = [oldHasConfirmedHealthCareProfession, hasConfirmedHealthCareProfession].contains { $0 == true }
                self.userDataRepository.hasConfirmedHealthCareProfession = newHasConfirmedHealthCareProfession

                if oldHasConfirmedHealthCareProfession == hasConfirmedHealthCareProfession {
                    self.monitor.debug("Current user configuration finished Synchronization with no updates", context: .synchronization)
                    completion(didAlreadySynchronizeData == false ? .notUpdated : .updated)
                } else {
                    self.monitor.debug("Current user configuration finished Synchronization with updates", context: .synchronization)
                    completion(.updated)
                }

            case .failure(let error):
                self.monitor.error(UserDataSynchronizerError.failedToFetchCurrentUserConfiguration(error), context: .synchronization)
                completion(.failed)
            }
        }
    }

    func removeAllDataFromLocalStorage() {
        userDataRepository.removeAllDataFromLocalStorage()
        featureFlagRepository.removeAllDataFromLocalStorage()
    }
}

extension UserDataSynchronizer {
    enum UserDataSynchronizerError: Error {
        case failedToFetchCurrentUserData(Error)
        case failedToFetchCurrentUserConfiguration(Error)
    }
}
