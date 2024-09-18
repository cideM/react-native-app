//
//  SettingsUserStageRepository.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 19.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

/// @mockable
protocol UserStageRepositoryType: AnyObject {
    func setUserStage(_ userStage: UserStage, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void)
    func getUserStage(completion: @escaping (Result<UserStage?, NetworkError<EmptyAPIError>>) -> Void)
}

final class SettingsUserStageRepository {

    private let userDataRepository: UserDataRepositoryType
    private let userDataClient: UserDataClient

    init(userDataRepository: UserDataRepositoryType = resolve(), userDataClient: UserDataClient) {
        self.userDataRepository = userDataRepository
        self.userDataClient = userDataClient
    }
}

extension SettingsUserStageRepository: UserStageRepositoryType {
    func setUserStage(_ userStage: UserStage, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void) {
        userDataClient.setUserStage(userStage) { [ weak self ] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.userDataRepository.userStage = userStage
                completion(.success(()))
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    func getUserStage(completion: @escaping (Result<UserStage?, NetworkError<EmptyAPIError>>) -> Void) {
        completion(.success(userDataRepository.userStage))
    }
}
