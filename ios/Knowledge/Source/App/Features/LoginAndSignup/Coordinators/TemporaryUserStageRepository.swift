//
//  TemporaryUserStageRepository.swift
//  Knowledge
//
//  Created by Cornelius Horstmann on 29.12.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

class TemporaryUserStageRepository {
    private(set) var userStage: UserStage? {
        didSet {
            NotificationCenter.default.post(UserStageDidChangeNotification(oldValue: oldValue, newValue: userStage), sender: self)
        }
    }
}

extension TemporaryUserStageRepository: UserStageRepositoryType {
    func setUserStage(_ userStage: UserStage, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void) {
        self.userStage = userStage
        completion(.success(()))
    }

    func getUserStage(completion: @escaping (Result<UserStage?, NetworkError<EmptyAPIError>>) -> Void) {
        completion(.success(userStage))
    }
}
