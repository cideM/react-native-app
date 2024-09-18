//
//  UserStageStorage.swift
//  Knowledge
//
//  Created by Aamir Suhial Mir on 19.02.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

final class UserStageRepository {

    private(set) var userStage: UserStage? {
        didSet {
            NotificationCenter.default.post(UserStageDidChangeNotification(oldValue: oldValue, newValue: userStage), sender: self)
        }
    }

    private let userDataRepository: UserDataRepositoryType

    init(userDataRepository: UserDataRepositoryType = resolve()) {
        self.userDataRepository = userDataRepository
    }
}

extension UserStageRepository: UserStageRepositoryType {
    func setUserStage(_ userStage: UserStage, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void) {
        self.userStage = userStage
        userDataRepository.userStage = userStage
        completion(.success(()))
    }

    func getUserStage(completion: @escaping (Result<UserStage?, NetworkError<EmptyAPIError>>) -> Void) {
        completion(.success(userDataRepository.userStage))
    }
}
