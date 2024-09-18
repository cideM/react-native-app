//
//  SettingsStudyObjectiveRepository.swift
//  Knowledge
//
//  Created by Silvio Bulla on 02.06.20.
//  Copyright © 2020 AMBOSS GmbH. All rights reserved.
//

import Domain
import Networking

final class SettingsStudyObjectiveRepository {

    private let userDataRepository: UserDataRepositoryType
    private let userDataClient: UserDataClient

    init(userDataRepository: UserDataRepositoryType = resolve(), userDataClient: UserDataClient) {
        self.userDataRepository = userDataRepository
        self.userDataClient = userDataClient
    }
}

extension SettingsStudyObjectiveRepository: StudyObjectiveRepositoryType {

    func getStudyObjectives(completion: @escaping (Result<[StudyObjective], NetworkError<EmptyAPIError>>) -> Void) {
        userDataClient.getAvailableStudyObjectives { result in
            switch result {
            case .success(let studyObjectives):
                completion(.success(studyObjectives))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func setStudyObjective(_ studyObjective: StudyObjective, completion: @escaping (Result<Void, NetworkError<EmptyAPIError>>) -> Void) {
        userDataClient.setStudyObjective(studyObjective) { [weak self] result in
            switch result {
            case .success:
                self?.userDataRepository.studyObjective = studyObjective
                completion(.success(()))
            case .failure(let error): completion(.failure(error))
            }
        }
    }

    func getStudyObjective(completion: @escaping (Result<StudyObjective?, NetworkError<EmptyAPIError>>) -> Void) {
        completion(.success(userDataRepository.studyObjective))
    }
}
